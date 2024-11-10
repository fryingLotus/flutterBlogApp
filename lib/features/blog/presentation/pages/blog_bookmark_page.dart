import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/entities/topic.dart';
import 'package:blogapp/features/blog/presentation/bloc/blog_bloc/blog_bloc.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_card.dart';
import 'package:blogapp/features/blog/presentation/widgets/custom_multi_select_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';

class BlogBookmarkPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const BlogBookmarkPage(),
      );

  const BlogBookmarkPage({super.key});

  @override
  State<BlogBookmarkPage> createState() => _BlogBookmarkPageState();
}

class _BlogBookmarkPageState extends State<BlogBookmarkPage> {
  late Box<bool> _likesBox;
  late Box<bool> _bookmarksBox;
  late String loggedInUserId;
  final List<Topic> _selectedTopics = [];
  List<Topic> _allBlogTopics = [];
  final Map<String, int> _localLikesCount = {};
  List<Blog> _currentBlogs = [];

  @override
  void initState() {
    super.initState();
    _initializeHiveBox();
    context.read<BlogBloc>().add(BlogFetchAllBlogTopics());
    context.read<BlogBloc>().stream.listen((state) {
      if (state is BlogTopicsDisplaySuccess) {
        setState(() {
          _allBlogTopics = state.topics;
        });
      }
    });
    _fetchBookmarkedBlogs();
  }

  void _initializeLocalLikesCount(List<Blog> blogs) {
    for (var blog in blogs) {
      _localLikesCount[blog.id] = blog.likes_count ?? 0;
    }
    setState(() {
      _currentBlogs = blogs;
    });
  }

  Future<void> _initializeHiveBox() async {
    _likesBox = Hive.box<bool>('likesBox');
    _bookmarksBox = Hive.box<bool>('bookmarksBox');
    loggedInUserId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
  }

  Future<void> _fetchBookmarkedBlogs() async {
    List<String> bookmarkedBlogIds = [];
    final allKeys = _bookmarksBox.keys;

    for (var key in allKeys) {
      if (key.toString().startsWith('${loggedInUserId}_')) {
        final isBookmarked =
            _bookmarksBox.get(key, defaultValue: false) ?? false;
        if (isBookmarked) {
          String blogId = key.toString().split('_')[1];
          bookmarkedBlogIds.add(blogId);
        }
      }
    }

    List<String>? topicIds = _selectedTopics.isNotEmpty
        ? _selectedTopics.map((topic) => topic.id).toList()
        : null;

    context.read<BlogBloc>().add(
          BlogFetchBookmarkedBlogs(
            blogIds: bookmarkedBlogIds,
            topicIds: topicIds,
          ),
        );
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
            _fetchBookmarkedBlogs();
          },
        );
      },
    );
  }

  Future<void> _toggleLike(String blogId, bool isLiked) async {
    try {
      final String uniqueKey = '${loggedInUserId}_$blogId';
      final currentCount = _localLikesCount[blogId] ?? 0;

      // Update local Hive storage
      _likesBox.put(uniqueKey, !isLiked);

      // Update local state
      setState(() {
        if (!isLiked) {
          _localLikesCount[blogId] = currentCount + 1;
        } else {
          _localLikesCount[blogId] = currentCount - 1;
        }

        _currentBlogs = _currentBlogs.map((blog) {
          if (blog.id == blogId) {
            return blog.copyWith(
              likes_count: _localLikesCount[blogId],
              isLiked: !isLiked,
            );
          }
          return blog;
        }).toList();
      });

      // Update server state
      if (isLiked) {
        context.read<BlogBloc>().add(BlogUnlike(blogId: blogId));
      } else {
        context.read<BlogBloc>().add(BlogLike(blogId: blogId));
      }
    } catch (e) {
      final String uniqueKey = '${loggedInUserId}_$blogId';
      _likesBox.put(uniqueKey, isLiked);
      showSnackBar(context, "An error has occurred", isError: true);
    }
  }

  Future<void> _toggleBookmark(String blogId) async {
    try {
      final String uniqueKey = '${loggedInUserId}_$blogId';
      final isCurrentlyBookmarked =
          _bookmarksBox.get(uniqueKey, defaultValue: false) ?? false;

      _bookmarksBox.put(uniqueKey, !isCurrentlyBookmarked);

      setState(() {
        if (!isCurrentlyBookmarked) {
          showSnackBar(context, "Added to bookmarks");
        } else {
          showSnackBar(context, "Removed from bookmarks");
          // Remove the blog from the current list
          _currentBlogs =
              _currentBlogs.where((blog) => blog.id != blogId).toList();
        }
      });
    } catch (e) {
      showSnackBar(context, "Failed to update bookmark", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmarks"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _openFilterBox(context),
            icon: const Icon(Icons.filter_list_sharp),
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(listener: (context, state) {
        if (state is BlogFailure) {
          showSnackBar(context, state.error, isError: true);
        } else if (state is BlogLikeSuccess || state is BlogUnlikeSuccess) {
          showSnackBar(context, "Success!");
        } else if (state is BlogsDisplayBookmarkSuccess) {
          _initializeLocalLikesCount(state.blogs);
        } else if (state is BlogDeleteSuccess) {
          _fetchBookmarkedBlogs();
        }
      }, builder: (context, state) {
        if (state is BlogLoading && _currentBlogs.isEmpty) {
          return const Loader();
        }

        final blogs =
            state is BlogsDisplayBookmarkSuccess ? state.blogs : _currentBlogs;
        return RefreshIndicator(
          onRefresh: _fetchBookmarkedBlogs,
          child: ListView.builder(
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              final blog = blogs[index];
              final String uniqueKey = '${loggedInUserId}_${blog.id}';
              final isLiked =
                  _likesBox.get(uniqueKey, defaultValue: false) ?? false;
              final updatedLikesCount =
                  _localLikesCount[blog.id] ?? blog.likes_count ?? 0;
              final isBookmarked =
                  _bookmarksBox.get(uniqueKey, defaultValue: false) ?? false;

              return BlogCard(
                key: ValueKey('${blog.id}_${updatedLikesCount}_$isLiked'),
                blog: blog.copyWith(likes_count: updatedLikesCount),
                color: index % 2 == 0
                    ? AppPallete.gradient1
                    : AppPallete.gradient2,
                isLiked: isLiked,
                isBookmarked: isBookmarked,
                onToggleBookmarked: () => _toggleBookmark(blog.id),
                onToggleLike: () => _toggleLike(blog.id, isLiked),
              );
            },
          ),
        );
      }),
    );
  }
}
