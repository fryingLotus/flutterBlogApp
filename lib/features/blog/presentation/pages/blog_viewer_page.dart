import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/calculate_reading_time.dart';
import 'package:blogapp/core/utils/format_date.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/presentation/bloc/blog_bloc/blog_bloc.dart';
import 'package:blogapp/features/blog/presentation/bloc/comment_bloc/comment_bloc.dart';
import 'package:blogapp/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_button.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogViewerPage extends StatefulWidget {
  static route(Blog blog) => MaterialPageRoute(
        builder: (context) => BlogViewerPage(blog: blog),
      );

  final Blog blog;

  const BlogViewerPage({super.key, required this.blog});

  @override
  State<BlogViewerPage> createState() => _BlogViewerPageState();
}

class _BlogViewerPageState extends State<BlogViewerPage> {
  final TextEditingController contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void _editBlog(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      AddNewBlogPage.route(blog: widget.blog),
    );
  }

  void _deleteBlog(BuildContext context) {
    context.read<BlogBloc>().add(BlogDelete(blogId: widget.blog.id));
  }

  void _uploadComment(BuildContext context) {
    final posterId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    context.read<CommentBloc>().add(CommentUpload(
        posterId: posterId,
        blogId: widget.blog.id,
        content: contentController.text.trim()));
    contentController.clear(); // Clear the text field after uploading
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<BlogBloc, BlogState>(
            listener: (context, state) {
              if (state is BlogFailure) {
                showSnackBar(context, state.error);
              } else if (state is BlogDeleteSuccess) {
                Navigator.pop(context);
                context.read<BlogBloc>().add(BlogFetchAllBlogs());
                showSnackBar(context, 'Successfully deleted blog');
              }
            },
          ),
          BlocListener<CommentBloc, CommentState>(
            listener: (context, state) {
              if (state is CommentFailure) {
                showSnackBar(context, state.error);
              } else if (state is CommentUploadSuccess) {
                showSnackBar(context, 'Comment posted successfully');
              }
            },
          ),
        ],
        child: BlocBuilder<BlogBloc, BlogState>(
          builder: (context, state) {
            if (state is BlogLoading) {
              return const Loader();
            }
            return Scrollbar(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.blog.title,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          BlogButton(
                            onEditTap: () => _editBlog(context),
                            onDeleteTap: () => _deleteBlog(context),
                          ),
                          GestureDetector(
                            child: const Icon(Icons.edit),
                            onTap: () {
                              Navigator.push(
                                context,
                                AddNewBlogPage.route(blog: widget.blog),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'By ${widget.blog.posterName}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16.0),
                      ),
                      Text(
                        '${formatDateBydMMMYYYY(widget.blog.updatedAt)} . ${calculateReadingTime(widget.blog.content)} mins',
                        style: const TextStyle(
                            color: AppPallete.greyColor, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.blog.imageUrl,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return const Loader();
                            }
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 200,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.blog.content,
                        style: const TextStyle(fontSize: 16.0, height: 2),
                      ),
                      const SizedBox(height: 40),
                      Form(
                        key: formKey,
                        child: Row(
                          children: [
                            Expanded(
                              child: BlogEditor(
                                controller: contentController,
                                hintText: 'Comment',
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                if (formKey.currentState?.validate() ?? false) {
                                  _uploadComment(context);
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
