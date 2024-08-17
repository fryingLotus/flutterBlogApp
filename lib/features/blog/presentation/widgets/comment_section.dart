import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/format_date.dart';
import 'package:blogapp/core/utils/show_options.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/blog/data/models/comment_model.dart';
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
  final GlobalKey<FormState> _uploadFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context
        .read<CommentBloc>()
        .add(CommentFetchAllForBlog(blogId: widget.blogId));
  }

  void _uploadComment(BuildContext context) {
    if (_uploadFormKey.currentState?.validate() ?? false) {
      final posterId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
      context.read<CommentBloc>().add(CommentUpload(
            posterId: posterId,
            blogId: widget.blogId,
            content: _contentController.text.trim(),
          ));
      _contentController.clear();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Widget _buildCommentForm(
      BuildContext context, TextEditingController controller,
      {String? hintText,
      void Function()? onSubmit,
      GlobalKey<FormState>? formKey}) {
    return Form(
      key: formKey ?? GlobalKey<FormState>(),
      child: BlogEditor(
        controller: controller,
        hintText: hintText ?? "Comment",
        suffixIcon: const Icon(
          Icons.send,
          color: AppPallete.gradient3,
        ),
        onSuffixIconPressed: () {
          if (formKey?.currentState?.validate() ?? false) {
            onSubmit?.call();
          }
        },
      ),
    );
  }

  void _editComment(
      BuildContext context, String commentId, String initialContent) {
    final TextEditingController editController =
        TextEditingController(text: initialContent);
    final GlobalKey<FormState> editFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: _buildCommentForm(context, editController,
              hintText: 'Edit your comment',
              formKey: editFormKey, onSubmit: () {
            if (editFormKey.currentState?.validate() ?? false) {
              context.read<CommentBloc>().add(CommentUpdate(
                    commentId: commentId,
                    content: editController.text.trim(),
                  ));
              Navigator.of(context).pop();
            }
          }),
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

  void _deleteComment(BuildContext context, String commentId) {
    context.read<CommentBloc>().add(CommentDelete(commentId: commentId));
  }

  Widget _buildCommentTile(BuildContext context, CommentModel comment) {
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
                      onEdit: () =>
                          _editComment(context, comment.id, comment.content),
                      onDelete: () => _deleteComment(context, comment.id),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentUploadSuccess) {
          context
              .read<CommentBloc>()
              .add(CommentFetchAllForBlog(blogId: widget.blogId));
          showSnackBar(context, 'Comment posted successfully');
        } else if (state is CommentDeleteSuccess) {
          context
              .read<CommentBloc>()
              .add(CommentFetchAllForBlog(blogId: widget.blogId));
          showSnackBar(context, 'Comment deleted successfully');
        } else if (state is CommentUpdateSuccess) {
          context
              .read<CommentBloc>()
              .add(CommentFetchAllForBlog(blogId: widget.blogId));
          showSnackBar(context, 'Comment updated successfully');
        } else if (state is CommentFailure) {
          showSnackBar(context, state.error, isError: true);
        }
      },
      builder: (context, state) {
        if (state is CommentLoading) {
          return const Loader();
        } else if (state is CommentFailure) {
          return Text(
            'Failed to load comments: ${state.error}',
            style: const TextStyle(color: Colors.red),
          );
        } else if (state is CommentsDisplaySuccess) {
          return Column(
            children: [
              _buildCommentForm(context, _contentController,
                  hintText: 'Add a comment',
                  onSubmit: () => _uploadComment(context),
                  formKey: _uploadFormKey), // Unique key for uploading
              const SizedBox(height: 20),
              if (state.comments.isEmpty)
                const Center(child: Text('No comments yet')),
              if (state.comments.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    final comment = state.comments[index];
                    final commentModel = CommentModel.fromComment(comment);
                    return _buildCommentTile(context, commentModel);
                  },
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
