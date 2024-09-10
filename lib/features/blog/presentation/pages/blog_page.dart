import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/presentation/bloc/blog_bloc/blog_bloc.dart';
import 'package:blogapp/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_card.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class BlogPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const BlogPage());
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  late Box<bool> _likesBox;
  static const int _pageSize = 10;
  final PagingController<int, Blog> _pagingController =
      PagingController(firstPageKey: 1);
  final Set<String> _loadedBlogIds = {};

  @override
  void initState() {
    super.initState();
    _openLikesBox();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _openLikesBox() async {
    _likesBox = await Hive.box<bool>(name: 'likesBox');
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final bloc = context.read<BlogBloc>();
      bloc.add(BlogFetchAllBlogs(page: pageKey, pageSize: _pageSize));

      bloc.stream
          .firstWhere((state) => state is BlogsDisplaySuccess)
          .then((state) {
        if (!mounted) return;

        final newItems = (state as BlogsDisplaySuccess).blogs;
        final filteredItems = newItems
            .where((blog) => !_loadedBlogIds.contains(blog.id))
            .toList();

        _loadedBlogIds.addAll(filteredItems.map((blog) => blog.id));
        final isLastPage = filteredItems.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(filteredItems);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(filteredItems, nextPageKey);
        }
      });
    } catch (error) {
      if (mounted) {
        _pagingController.error = error;
      }
    }
  }

  Future<void> _toggleLike(String blogId, bool isLiked) async {
    try {
      if (isLiked) {
        context.read<BlogBloc>().add(BlogUnlike(blogId: blogId));
      } else {
        context.read<BlogBloc>().add(BlogLike(blogId: blogId));
      }

      // Update the local Hive box
      _likesBox.put(blogId, !isLiked);

      // Optionally, refetch to update the UI with the latest blog data
      // This is useful if the like count is not updated immediately
      context
          .read<BlogBloc>()
          .add(BlogFetchAllBlogs(page: 1, pageSize: _pageSize));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'For You'),
              Tab(
                child: Center(
                  child: Text('Following'),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBlogListView(), // Tab 1: All Blogs
            Center(child: Text('Blog')), // Tab 2: Blog centered text
          ],
        ),
        drawer: const MyDrawer(),
      ),
    );
  }

  Widget _buildBlogListView() {
    return PagedListView<int, Blog>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Blog>(
        itemBuilder: (context, blog, index) {
          final isLiked = _likesBox.get(blog.id, defaultValue: false) ?? false;
          final updatedLikesCount = blog.likes_count ??
              0; // Use the latest count from the blog object

          return BlogCard(
            key: ValueKey(blog.id),
            blog: blog.copyWith(likes_count: updatedLikesCount),
            color: index % 2 == 0 ? AppPallete.gradient1 : AppPallete.gradient2,
            isLiked: isLiked,
            onToggleLike: () async {
              await _toggleLike(blog.id, isLiked);
              setState(() {}); // Ensure UI updates with the latest state
            },
          );
        },
      ),
    );
  }
}

