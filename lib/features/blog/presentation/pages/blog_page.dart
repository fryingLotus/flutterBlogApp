import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
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
    _likesBox = Hive.box<bool>(name: 'likesBox');
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final bloc = context.read<BlogBloc>();
      bloc.add(BlogFetchAllBlogs(page: pageKey, pageSize: _pageSize));

      bloc.stream
          .firstWhere((state) => state is BlogsDisplaySuccess)
          .then((state) {
        if (!mounted) return; // Ensure the widget is still mounted

        final newItems = (state as BlogsDisplaySuccess).blogs;

        // Filter out duplicate blogs
        final filteredItems = newItems
            .where((blog) => !_loadedBlogIds.contains(blog.id))
            .toList();

        // Add the new unique blog IDs to the set
        _loadedBlogIds.addAll(filteredItems.map((blog) => blog.id));
        final isLastPage = filteredItems.length < _pageSize;
        print('Filtered Items: ${filteredItems.length}');
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

      // Update local storage
      _likesBox.put(blogId, !isLiked);
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
    return Scaffold(
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
      body: PagedListView<int, Blog>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Blog>(
          itemBuilder: (context, blog, index) {
            final isLiked =
                _likesBox.get(blog.id, defaultValue: false) ?? false;
            final updatedLikesCount =
                isLiked ? (blog.likes_count ?? 0) + 1 : (blog.likes_count ?? 0);

            return BlogCard(
              key: ValueKey(blog.id),
              blog: blog.copyWith(likes_count: updatedLikesCount),
              color:
                  index % 2 == 0 ? AppPallete.gradient1 : AppPallete.gradient2,
              isLiked: isLiked,
              onToggleLike: () async {
                await _toggleLike(blog.id, isLiked);
                setState(() {}); // Refresh UI after updating like status
              },
            );
          },
        ),
      ),
      drawer: const MyDrawer(),
    );
  }
}
