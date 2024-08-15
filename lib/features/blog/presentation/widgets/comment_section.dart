import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/format_date.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/blog/presentation/bloc/comment_bloc/comment_bloc.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentSection extends StatefulWidget {
  final String blogId;

  const CommentSection({
    super.key,
    required this.blogId,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Fetch the comments when the widget is initialized
    context
        .read<CommentBloc>()
        .add(CommentFetchAllForBlog(blogId: widget.blogId));
  }

  void _uploadComment(BuildContext context) {
    final posterId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    context.read<CommentBloc>().add(CommentUpload(
        posterId: posterId,
        blogId: widget.blogId,
        content: _contentController.text.trim()));
    _contentController.clear();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentUploadSuccess) {
          // Fetch comments after a successful upload
          context
              .read<CommentBloc>()
              .add(CommentFetchAllForBlog(blogId: widget.blogId));
          showSnackBar(context, 'Comment posted successfully');
        } else if (state is CommentFailure) {
          showSnackBar(context, state.error);
        }
      },
      child: Column(
        children: [
          Form(
            key: formKey,
            child: BlogEditor(
              controller: _contentController,
              hintText: "Comment",
              suffixIcon: const Icon(
                Icons.send,
                color: AppPallete.gradient3,
              ),
              onSuffixIconPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  _uploadComment(context);
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              if (state is CommentLoading) {
                return const Loader();
              } else if (state is CommentFailure) {
                Text(
                  'Failed to load comments: ${state.error}',
                  style: const TextStyle(color: Colors.red),
                );
                showSnackBar(context, state.error);
              } else if (state is CommentsDisplaySuccess) {
                if (state.comments.isEmpty) {
                  return const Text(
                      "No comments yet. Be the first to comment!");
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    final comment = state.comments[index];
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${comment.posterName}'),
                                  const Icon(Icons.more_vert)
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
                          const SizedBox(
                              height: 4), // Space between date and content
                          Text(
                            comment.content,
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow
                                .visible, // Ensure it wraps to the next line
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

