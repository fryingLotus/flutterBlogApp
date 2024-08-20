import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/format_date.dart';
import 'package:blogapp/core/utils/show_options.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/blog/data/models/comment_model.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/like_comment.dart';
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
  final List<CommentModel> _comments = [];

  late Box<bool> _likesBox;
  int _currentPage = 1;
  bool _hasMoreComments = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _openLikesBox();
    _fetchComments();

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

  Future<void> _openLikesBox() async {
    _likesBox = await Hive.box<bool>(name: 'commentLikesBox');
  }

  Future<void> _toggleLike(String commentId, bool isLiked) async {
    try {
      if (isLiked) {
        context.read<CommentBloc>().add(CommentUnlike(commentId: commentId));
        _comments.clear();
      } else {
        context.read<CommentBloc>().add(CommentLike(commentId: commentId));
        _comments.clear();
      }
      _likesBox.put(commentId, !isLiked);
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
    return BlocConsumer<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentUploadSuccess ||
            state is CommentDeleteSuccess ||
            state is CommentUpdateSuccess) {
          _fetchComments();
          showSnackBar(context, 'Action completed successfully');
        } else if (state is CommentLikeSuccess ||
            state is CommentUnlikeSuccess) {
          _fetchComments();
          showSnackBar(context, "Success!");
        } else if (state is CommentFailure) {
          showSnackBar(context, state.error, isError: true);
        } else if (state is CommentLoadingMore) {
          _isLoadingMore = true;
        } else if (state is CommentsDisplaySuccess) {
          _comments.addAll(state.comments
              .map((comment) => CommentModel.fromComment(comment)));
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
              if (state.comments.isNotEmpty) _buildCommentsList(),
            ],
            if (_isLoadingMore)
              const Center(child: CircularProgressIndicator()),
          ],
        );
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

  Widget _buildCommentsList() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 500),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children:
              _comments.map((comment) => _buildCommentTile(comment)).toList(),
        ),
      ),
    );
  }

  Widget _buildCommentTile(CommentModel comment) {
    final isLiked = _likesBox.get(comment.id, defaultValue: false) ?? false;
    final updatedLikesCount =
        isLiked ? (comment.likes_count ?? 0) + 1 : (comment.likes_count ?? 0);

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${comment.posterName}'),
                  GestureDetector(
                    onTap: () => showOptions(
                      context: context,
                      onEdit: () => _editComment(comment.id, comment.content),
                      onDelete: () => _deleteComment(comment.id),
                      commentId: comment.id,
                    ),
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
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
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            comment.content,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.visible,
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$updatedLikesCount'),
          IconButton(
            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : null),
            onPressed: () async {
              await _toggleLike(comment.id, isLiked);
              setState(() {});
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
          content: _buildCommentForm(),
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
          content: _contentController.text.trim(),
          posterId: posterId,
        ));
    _contentController.clear();
  }
}
