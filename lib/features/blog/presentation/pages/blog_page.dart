import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
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

class _BlogPageState extends State<BlogPage>
    with SingleTickerProviderStateMixin {
  late Box<bool> _likesBox;
  static const int _pageSize = 10;
  late TabController _tabController;
  final PagingController<int, Blog> _allBlogsPagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, Blog> _followedBlogsPagingController =
      PagingController(firstPageKey: 1);
  final Set<String> _loadedAllBlogIds = {};
  final Set<String> _loadedFollowedBlogIds = {};

  @override
  void initState() {
    super.initState();
    _openLikesBox();
    _tabController = TabController(length: 2, vsync: this);

    _allBlogsPagingController.addPageRequestListener((pageKey) {
      _fetchAllBlogsPage(pageKey);
    });

    _followedBlogsPagingController.addPageRequestListener((pageKey) {
      _fetchFollowedBlogsPage(pageKey);
    });
  }

  Future<void> _openLikesBox() async {
    _likesBox = Hive.box<bool>(name: 'likesBox');
  }

  Future<void> _fetchAllBlogsPage(int pageKey) async {
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
            .where((blog) => !_loadedAllBlogIds.contains(blog.id))
            .toList();

        // Add the new unique blog IDs to the set
        _loadedAllBlogIds.addAll(filteredItems.map((blog) => blog.id));
        final isLastPage = filteredItems.length < _pageSize;
        if (isLastPage) {
          _allBlogsPagingController.appendLastPage(filteredItems);
        } else {
          final nextPageKey = pageKey + 1;
          _allBlogsPagingController.appendPage(filteredItems, nextPageKey);
        }
      });
    } catch (error) {
      if (mounted) {
        _allBlogsPagingController.error = error;
      }
    }
  }

  Future<void> _fetchFollowedBlogsPage(int pageKey) async {
    try {
      final bloc = context.read<BlogBloc>();

      print('Fetching blogs for page $pageKey');
      // Dispatch the event to fetch followed blogs
      bloc.add(BlogFetchUserFollowBlogs(page: pageKey, pageSize: _pageSize));

      // Listen for the state
      await for (final state in bloc.stream) {
        if (state is BlogsDisplayUserFollowSuccess) {
          if (!mounted) {
            print('Widget not mounted');
            return; // Ensure the widget is still mounted
          }

          final newItems = state.blogs; // This should be List<BlogModel>
          print('Fetched blogs: ${newItems.length}');

          // Log current loaded blog IDs
          print('Loaded blog IDs: $_loadedFollowedBlogIds');

          // Filter out duplicate blogs
          final filteredItems = newItems
              .where((blog) => !_loadedFollowedBlogIds.contains(blog.id))
              .toList();
          print('Filtered items: ${filteredItems.length}');

          // Add the new unique blog IDs to the set
          _loadedFollowedBlogIds.addAll(filteredItems.map((blog) => blog.id));

          final isLastPage = filteredItems.length < _pageSize;
          if (isLastPage) {
            _followedBlogsPagingController.appendLastPage(filteredItems);
            print('Last page reached');
          } else {
            final nextPageKey = pageKey + 1;
            _followedBlogsPagingController.appendPage(
                filteredItems, nextPageKey);
            print('Next page key: $nextPageKey');
          }

          break; // Exit the loop after processing the successful state
        } else if (state is BlogFailure) {
          // Handle any error states if necessary
          if (mounted) {
            print('Error fetching followed blogs: ${state.error}');
            _followedBlogsPagingController.error =
                state.error; // Handle error accordingly
          }
          break; // Exit on error state
        }
      }
    } catch (error) {
      if (mounted) {
        print('Error fetching followed blogs: $error');
        _followedBlogsPagingController.error = error;
      }
    }
  }

  Future<void> _toggleLike(String blogId, bool isLiked) async {
    try {
      final userId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
      final String uniqueKey = '${userId}_$blogId';

      // Dispatch the appropriate event based on the current like status
      if (isLiked) {
        context.read<BlogBloc>().add(BlogUnlike(blogId: blogId));
      } else {
        context.read<BlogBloc>().add(BlogLike(blogId: blogId));
      }

      // Update local storage immediately
      _likesBox.put(uniqueKey, !isLiked);

      // Refresh the UI for the specific blog card
      setState(() {});
    } catch (e) {
      showSnackBar(context, "An error has occurred", isError: true);
    }
  }

  @override
  void dispose() {
    _allBlogsPagingController.dispose();
    _followedBlogsPagingController.dispose();
    _tabController.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Blogs'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PagedListView<int, Blog>(
            pagingController: _allBlogsPagingController,
            builderDelegate: PagedChildBuilderDelegate<Blog>(
              itemBuilder: (context, blog, index) {
                final String userId =
                    (context.read<AppUserCubit>().state as AppUserLoggedIn)
                        .user
                        .id;
                final String uniqueKey = '${userId}_${blog.id}';

                // Check if the blog is liked from the local storage (Hive)
                final isLiked =
                    _likesBox.get(uniqueKey, defaultValue: false) ?? false;
                final updatedLikesCount = isLiked
                    ? (blog.likes_count ?? 0) + 1
                    : (blog.likes_count ?? 0);

                return BlogCard(
                  key: ValueKey(blog.id),
                  blog: blog.copyWith(likes_count: updatedLikesCount),
                  color: index % 2 == 0
                      ? AppPallete.gradient1
                      : AppPallete.gradient2,
                  isLiked: isLiked,
                  onToggleLike: () async {
                    await _toggleLike(blog.id, isLiked);
                  },
                );
              },
            ),
          ),
          PagedListView<int, Blog>(
            pagingController: _followedBlogsPagingController,
            builderDelegate: PagedChildBuilderDelegate<Blog>(
              itemBuilder: (context, blog, index) {
                final String userId =
                    (context.read<AppUserCubit>().state as AppUserLoggedIn)
                        .user
                        .id;
                final String uniqueKey = '${userId}_${blog.id}';

                // Check if the blog is liked from the local storage (Hive)
                final isLiked =
                    _likesBox.get(uniqueKey, defaultValue: false) ?? false;
                final updatedLikesCount = isLiked
                    ? (blog.likes_count ?? 0) + 1
                    : (blog.likes_count ?? 0);

                return BlogCard(
                  key: ValueKey(blog.id),
                  blog: blog.copyWith(likes_count: updatedLikesCount),
                  color: index % 2 == 0
                      ? AppPallete.gradient1
                      : AppPallete.gradient2,
                  isLiked: isLiked,
                  onToggleLike: () async {
                    await _toggleLike(blog.id, isLiked);
                  },
                );
              },
            ),
          ),
        ],
      ),
      drawer: const MyDrawer(),
    );
  }
}
