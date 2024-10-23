import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/format_date.dart';
import 'package:blogapp/core/utils/show_options.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/blog/data/models/comment_model.dart';
import 'package:blogapp/features/blog/domain/entities/comment.dart';
import 'package:blogapp/features/blog/presentation/bloc/comment_bloc/comment_bloc.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class CommentSection extends StatefulWidget {
  final String blogId;

  const CommentSection({Key? key, required this.blogId}) : super(key: key);

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _uploadFormKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  late Box<bool> _likesBox;
  int _currentPage = 1;
  bool _hasMoreComments = true;
  bool _isLoadingMore = false;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore) {
        if (_hasMoreComments) {
          _currentPage++;
          _fetchComments();
        }
      }
    });
  }

  Future<void> _initialize() async {
    await _openLikesBox();
    _fetchComments();
  }

  Future<void> _openLikesBox() async {
    _likesBox = await Hive.box<bool>(name: 'commentLikesBox');
  }

  Future<void> _toggleLike(String commentId, bool isLiked) async {
    try {
      final userId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
      final String uniqueKey =
          '${userId}_$commentId'; // Composite key of userId and commentId

      if (isLiked) {
        context.read<CommentBloc>().add(CommentUnlike(commentId: commentId));
      } else {
        context.read<CommentBloc>().add(CommentLike(commentId: commentId));
      }

      _likesBox.put(
          uniqueKey, !isLiked); // Use the uniqueKey instead of just commentId
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader(); // Show a loading indicator while initializing
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return BlocConsumer<CommentBloc, CommentState>(
            listener: (context, state) {
              if (state is CommentUploadSuccess) {
                _fetchComments();
                showSnackBar(context, 'Comment Uploaded successfully');
              } else if (state is CommentDeleteSuccess) {
                _fetchComments();
                showSnackBar(context, "Comment deleted successfully");
              } else if (state is CommentUpdateSuccess) {
                _fetchComments();
                showSnackBar(context, "Comment updated successfully");
              } else if (state is CommentLikeSuccess ||
                  state is CommentUnlikeSuccess) {
                setState(() {});
                //_fetchComments();
                showSnackBar(context, "Success!");
              } else if (state is CommentFailure) {
                showSnackBar(context, state.error, isError: true);
              } else if (state is CommentLoadingMore) {
                _isLoadingMore = true;
              } else if (state is CommentsDisplaySuccess) {
                final commentModels = state.comments
                    .map((comment) => CommentModel.fromComment(comment))
                    .toList();
                _hasMoreComments = state.hasMore;
                _isLoadingMore = false;
              }
            },
            builder: (context, state) {
              if (state is CommentLoading && _currentPage == 1) {
                return const Loader();
              }
              return Column(
                children: [
                  _buildCommentForm(),
                  const SizedBox(height: 20),
                  if (state is CommentsDisplaySuccess) ...[
                    if (state.comments.isEmpty)
                      const Center(child: Text('No comments yet')),
                    if (state.comments.isNotEmpty)
                      _buildCommentsList(state.comments),
                  ],
                  if (_isLoadingMore)
                    const Center(child: CircularProgressIndicator()),
                ],
              );
            },
          );
        }
      },
    );
  }

  Widget _buildCommentForm() {
    return Form(
      key: _uploadFormKey,
      child: BlogEditor(
        controller: _contentController,
        hintText: "Add a comment",
        suffixIcon: const Icon(Icons.send, color: AppPallete.gradient3),
        onSuffixIconPressed: () {
          if (_uploadFormKey.currentState?.validate() ?? false) {
            _uploadComment();
          }
        },
      ),
    );
  }

  Widget _buildCommentsList(List<Comment> comments) {
    for (var comment in comments) {
      print("Comments:"); // This will print each comment in the console
      print(comment.toString()); // This will print each comment in the console
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 500),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children:
              comments.map((comment) => _buildCommentTile(comment)).toList(),
        ),
      ),
    );
  }

  Widget _buildCommentTile(Comment comment) {
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    final String uniqueKey = '${userId}_${comment.id}';
    final isLiked = _likesBox.get(uniqueKey, defaultValue: false) ?? false;
    final updatedLikesCount = comment.likes_count ?? 0;

    return ListTile(
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: comment.posterAvatar != null
                ? NetworkImage(comment.posterAvatar!)
                : null,
            child: comment.posterAvatar == null
                ? const Icon(Icons.account_circle, size: 40)
                : null,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${comment.posterName}'),
              Text(
                formatDateBydMMMYYYY(comment.updatedAt),
                style: const TextStyle(
                  color: AppPallete.greyColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
      subtitle: Text(comment.content),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$updatedLikesCount"),
          IconButton(
            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : null),
            onPressed: () async {
              await _toggleLike(comment.id, isLiked);
            },
          ),
        ],
      ),
    );
  }

  void _deleteComment(String commentId) {
    context.read<CommentBloc>().add(CommentDelete(commentId: commentId));
  }

  void _editComment(String commentId, String initialContent) {
    final TextEditingController editController =
        TextEditingController(text: initialContent);
    final GlobalKey<FormState> editFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: Form(
            key: editFormKey,
            child: BlogEditor(
              controller: editController,
              hintText: "Edit your comment",
              suffixIcon: const Icon(Icons.save),
              onSuffixIconPressed: () {
                if (editFormKey.currentState?.validate() ?? false) {
                  context.read<CommentBloc>().add(CommentUpdate(
                        commentId: commentId,
                        content: editController.text.trim(),
                      ));
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (editFormKey.currentState?.validate() ?? false) {
                  context.read<CommentBloc>().add(CommentUpdate(
                        commentId: commentId,
                        content: editController.text.trim(),
                      ));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _fetchComments({bool fetchPrevious = false}) {
    if (fetchPrevious && _currentPage <= 0) return;

    if (_currentPage == 1 && !_isLoadingMore) {
      // Clear the list only when fetching the first page (initial load or refresh)
    }

    context.read<CommentBloc>().add(
          CommentFetchAllForBlog(
            blogId: widget.blogId,
            page: _currentPage,
            pageSize: 10,
          ),
        );
  }

  void _uploadComment() {
    final posterId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    context.read<CommentBloc>().add(CommentUpload(
          blogId: widget.blogId,
          posterId: posterId,
          content: _contentController.text.trim(),
        ));
    _contentController.clear();
  }
}
