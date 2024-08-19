import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/blog/presentation/bloc/blog_bloc/blog_bloc.dart';
import 'package:blogapp/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_card.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const BlogPage());
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final Map<String, bool> _likedBlogs = {};

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  Future<void> _fetchBlogs() async {
    context.read<BlogBloc>().add(BlogFetchAllBlogs());
  }

  Future<void> _toggleLike(String blogId, bool isLiked) async {
    try {
      if (isLiked) {
        // Unlike the blog
        context.read<BlogBloc>().add(BlogUnlike(blogId: blogId));
      } else {
        // Like the blog
        context.read<BlogBloc>().add(BlogLike(blogId: blogId));
      }
      setState(() {
        _likedBlogs[blogId] = !isLiked;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _fetchBlogs();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('D I B L O G'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, AddNewBlogPage.route());
              },
              icon: const Icon(CupertinoIcons.add_circled),
            )
          ],
        ),
        body: BlocConsumer<BlogBloc, BlogState>(
          listener: (context, state) {
            if (state is BlogFailure) {
              showSnackBar(context, state.error, isError: true);
            } else if (state is BlogLikeSuccess || state is BlogUnlikeSuccess) {
              _fetchBlogs();

              showSnackBar(context, "Success!");
            }
          },
          builder: (context, state) {
            if (state is BlogLoading) {
              return const Loader();
            }
            if (state is BlogsDisplaySuccess) {
              return RefreshIndicator(
                onRefresh: _fetchBlogs,
                child: ListView.builder(
                  itemCount: state.blogs.length,
                  itemBuilder: (context, index) {
                    final blog = state.blogs[index];
                    final isLiked = _likedBlogs[blog.id] ?? false;
                    return BlogCard(
                      key: ValueKey(blog.id),
                      blog: blog,
                      color: index % 2 == 0
                          ? AppPallete.gradient1
                          : AppPallete.gradient2,
                      isLiked: isLiked,
                      onToggleLike: () => _toggleLike(blog.id, isLiked),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        drawer: const MyDrawer(),
      ),
    );
  }
}
