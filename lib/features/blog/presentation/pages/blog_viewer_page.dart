import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/calculate_reading_time.dart';
import 'package:blogapp/core/utils/format_date.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/presentation/bloc/blog_bloc/blog_bloc.dart';
import 'package:blogapp/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogViewerPage extends StatelessWidget {
  static route(Blog blog) => MaterialPageRoute(
        builder: (context) => BlogViewerPage(blog: blog),
      );

  final Blog blog;

  const BlogViewerPage({super.key, required this.blog});

  void _editBlog(BuildContext context) {
    Navigator.push(
      context,
      AddNewBlogPage.route(blog: blog),
    );
  }

  void _deleteBlog(BuildContext context) {
    // Check if blog.id is not null
    print("Delete blog id ${blog.id}");
    context.read<BlogBloc>().add(BlogDelete(blogId: blog.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is BlogDeleteSuccess) {
            Navigator.pop(context);
            context.read<BlogBloc>().add(BlogFetchAllBlogs());
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Succesfully deleting blog')));
          }
        },
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
                          blog.title,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        BlogButton(
                          onEditTap: () => _editBlog(context),
                          onDeleteTap: () => _deleteBlog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'By ${blog.posterName}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 16.0),
                    ),
                    Text(
                      '${formatDateBydMMMYYYY(blog.updatedAt)} . ${calculateReadingTime(blog.content)} mins',
                      style: const TextStyle(
                          color: AppPallete.greyColor, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        blog.imageUrl,
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
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      blog.content,
                      style: const TextStyle(fontSize: 16.0, height: 2),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
