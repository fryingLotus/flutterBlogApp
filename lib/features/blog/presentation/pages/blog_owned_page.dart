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

class BlogOwnedPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const BlogOwnedPage());
  const BlogOwnedPage({super.key});

  @override
  State<BlogOwnedPage> createState() => _BlogOwnedPageState();
}

class _BlogOwnedPageState extends State<BlogOwnedPage> {
  final Map<String, bool> _likedBlogs = {};

  @override
  void initState() {
    super.initState();
    print('Fetching user blogs...');
    context.read<BlogBloc>().add(BlogFetchUserBlogs());
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Blogs'),
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
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          }
          if (state is UserBlogsDisplaySuccess) {
            print('User blogs loaded: ${state.userBlogs.length}');
            return ListView.builder(
              itemCount: state.userBlogs.length,
              itemBuilder: (context, index) {
                final blog = state.userBlogs[index];
                final isLiked = _likedBlogs[blog.id] ?? false;
                return BlogCard(
                  blog: blog,
                  color: index % 2 == 0
                      ? AppPallete.gradient1
                      : AppPallete.gradient2,
                  isLiked: isLiked,
                  onToggleLike: () => _toggleLike(blog.id, isLiked),
                );
              },
            );
          }
          return const SizedBox
              .shrink(); // Return an empty widget if no state matches
        },
      ),
      drawer: const MyDrawer(),
    );
  }
}
