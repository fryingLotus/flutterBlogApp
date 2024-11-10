import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/entities/topic.dart';
import 'package:blogapp/features/blog/presentation/bloc/blog_bloc/blog_bloc.dart';
import 'package:blogapp/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_card.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_drawer.dart';
import 'package:blogapp/features/blog/presentation/widgets/custom_multi_select_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
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
  late Box<bool> _bookmarksBox;
  static const int _pageSize = 10;
  late TabController _tabController;
  final PagingController<int, Blog> _allBlogsPagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, Blog> _followedBlogsPagingController =
      PagingController(firstPageKey: 1);
  final Set<String> _loadedAllBlogIds = {};
  final Set<String> _loadedFollowedBlogIds = {};
  final List<Topic> _selectedTopics = [];

  List<Topic> _allBlogTopics = [];

  @override
  void initState() {
    super.initState();
    _openHivesBox();
    _tabController = TabController(length: 2, vsync: this);

    context.read<BlogBloc>().add(BlogFetchAllBlogTopics());
    context.read<BlogBloc>().stream.listen((state) {
      if (state is BlogTopicsDisplaySuccess) {
        setState(() {
          _allBlogTopics = state.topics;
        });
      }
    });

    _allBlogsPagingController.addPageRequestListener((pageKey) {
      _fetchAllBlogsPage(pageKey);
    });

    _followedBlogsPagingController.addPageRequestListener((pageKey) {
      _fetchFollowedBlogsPage(pageKey);
    });
  }

  Future<void> _openHivesBox() async {
    _likesBox = Hive.box<bool>('likesBox');
    _bookmarksBox = Hive.box<bool>('bookmarksBox');
  }

  Future<void> _fetchAllBlogsPage(int pageKey) async {
    try {
      final bloc = context.read<BlogBloc>();
      List<String>? topicIds = _selectedTopics.isNotEmpty
          ? _selectedTopics.map((topic) => topic.id).toList()
          : null;

      bloc.add(BlogFetchAllBlogs(
        topicIds: topicIds,
        page: pageKey,
        pageSize: _pageSize,
      ));

      bloc.stream
          .firstWhere((state) => state is BlogsDisplaySuccess)
          .then((state) {
        if (!mounted) return;

        final newItems = (state as BlogsDisplaySuccess).blogs;

        for (var blog in newItems) {}

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

      // Get selected topic IDs
      List<String>? topicIds = _selectedTopics.isNotEmpty
          ? _selectedTopics.map((topic) => topic.id).toList()
          : null;

      if (pageKey == 1) {
        _loadedFollowedBlogIds.clear();
        _followedBlogsPagingController.refresh();
      }

      bloc.add(BlogFetchUserFollowBlogs(
          topicIds: topicIds, page: pageKey, pageSize: _pageSize));

      bloc.stream
          .firstWhere((state) => state is BlogsDisplayUserFollowSuccess)
          .then((state) {
        if (!mounted) return;

        final newItems = (state as BlogsDisplayUserFollowSuccess).blogs;

        final filteredItems = newItems
            .where((blog) => !_loadedFollowedBlogIds.contains(blog.id))
            .toList();

        _loadedFollowedBlogIds.addAll(filteredItems.map((blog) => blog.id));

        final isLastPage = filteredItems.length < _pageSize;

        if (isLastPage) {
          _followedBlogsPagingController.appendLastPage(filteredItems);
        } else {
          final nextPageKey = pageKey + 1;
          _followedBlogsPagingController.appendPage(filteredItems, nextPageKey);
        }
      });
    } catch (error) {
      if (mounted) {
        _followedBlogsPagingController.error = error;
      }
    }
  }

  void _openFilterBox(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return CustomMultiSelectDialog(
          allTopics: _allBlogTopics,
          selectedTopics: _selectedTopics,
          onConfirm: (selectedTopics) {
            setState(() {
              _selectedTopics.clear();
              _selectedTopics.addAll(selectedTopics);
            });

            _refreshBlogs();
          },
        );
      },
    );
  }

  Future<void> _toggleBookmark(String blogId) async {
    try {
      final userId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
      final String uniqueKey = '${userId}_$blogId';

      final isCurrentlyBookmarked =
          _bookmarksBox.get(uniqueKey, defaultValue: false) ?? false;

      _bookmarksBox.put(uniqueKey, !isCurrentlyBookmarked);

      if (mounted) {
        showSnackBar(
            context,
            !isCurrentlyBookmarked
                ? "Added to bookmarks"
                : "Removed from bookmarks");
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, "Failed to update bookmark", isError: true);
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
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      showSnackBar(context, "An error has occurred", isError: true);
    }
  }

  void _refreshBlogs() {
    _allBlogsPagingController.refresh();
    _followedBlogsPagingController.refresh();
    _loadedAllBlogIds.clear();
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
          ),
          IconButton(
            onPressed: () {
              _openFilterBox(context);
            },
            icon: const Icon(Icons.filter_list_sharp),
          ),
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

                final isLiked =
                    _likesBox.get(uniqueKey, defaultValue: false) ?? false;
                final isBookmarked =
                    _bookmarksBox.get(uniqueKey, defaultValue: false) ?? false;
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
                  isBookmarked: isBookmarked,
                  onToggleBookmarked: () async {
                    await _toggleBookmark(blog.id);
                  },
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
                final isBookmarked =
                    _bookmarksBox.get(uniqueKey, defaultValue: false) ?? false;
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
                  isBookmarked: isBookmarked,
                  onToggleBookmarked: () async {
                    await _toggleBookmark(blog.id);
                  },
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
