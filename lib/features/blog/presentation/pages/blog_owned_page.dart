import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/entities/topic.dart';
import 'package:blogapp/features/blog/presentation/bloc/blog_bloc/blog_bloc.dart';
import 'package:blogapp/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_card.dart';
import 'package:blogapp/features/blog/presentation/widgets/custom_multi_select_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';

class BlogOwnedPage extends StatefulWidget {
  final String userId;

  const BlogOwnedPage({super.key, required this.userId});

  // Updated the route method to take userId as an argument
  static Route route(String userId) =>
      MaterialPageRoute(builder: (context) => BlogOwnedPage(userId: userId));

  @override
  State<BlogOwnedPage> createState() => _BlogOwnedPageState();
}

class _BlogOwnedPageState extends State<BlogOwnedPage> {
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
    _fetchUserBlogs();
    // Get the logged-in user's ID
    loggedInUserId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
  }

  void _initializeLocalLikesCount(List<Blog> blogs) {
    for (var blog in blogs) {
      _localLikesCount[blog.id] = blog.likes_count ?? 0;
    }
    _currentBlogs = blogs;
  }

  Future<void> _initializeHiveBox() async {
    _likesBox = await Hive.box<bool>('likesBox');
    _bookmarksBox = await Hive.box<bool>('bookmarksBox');
  }

  Future<void> _fetchUserBlogs() async {
    List<String>? topicIds = _selectedTopics.isNotEmpty
        ? _selectedTopics.map((topic) => topic.id).toList()
        : null;
    context
        .read<BlogBloc>()
        .add(BlogFetchUserBlogs(userId: widget.userId, topicIds: topicIds));
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

            // Print the selected topics
            print("Selected Topics:");
            for (var selected in _selectedTopics) {
              print("Topic ID: ${selected.id}, Topic Name: ${selected.name}");
            }

            // Refresh the blogs list with the new filter
            _fetchUserBlogs();
          },
        );
      },
    );
  }

  Future<void> _toggleLike(String blogId, bool isLiked) async {
    try {
      final String uniqueKey = '${loggedInUserId}_$blogId';
      final currentCount = _localLikesCount[blogId] ?? 0;

      _likesBox.put(uniqueKey, !isLiked);

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

  @override
  Widget build(BuildContext context) {
    // Determine if we're viewing the logged-in user's blogs
    final bool isOwnProfile = loggedInUserId == widget.userId;

    return WillPopScope(
      onWillPop: () async {
        _fetchUserBlogs();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(isOwnProfile ? 'My Blogs' : 'User Blogs'),
          leading: isOwnProfile
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
          actions: [
            if (isOwnProfile)
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
        ),
        body: BlocConsumer<BlogBloc, BlogState>(
          listener: (context, state) {
            if (state is BlogFailure) {
              showSnackBar(context, state.error, isError: true);
            } else if (state is BlogLikeSuccess || state is BlogUnlikeSuccess) {
              //_fetchUserBlogs();
              showSnackBar(context, "Success!");
            } else if (state is UserBlogsDisplaySuccess) {
              // Initialize local likes count when blogs are loaded
              _initializeLocalLikesCount(state.userBlogs);
            } else if (state is BlogDeleteSuccess) {
              _fetchUserBlogs();
            }
          },
          builder: (context, state) {
            if (state is BlogLoading) {
              return const Loader();
            }

            final blogs = state is UserBlogsDisplaySuccess
                ? state.userBlogs
                : _currentBlogs;

            if (blogs.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: _fetchUserBlogs,
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
                        _bookmarksBox.get(uniqueKey, defaultValue: false) ??
                            false;
                    return BlogCard(
                      key: ValueKey('${blog.id}_${updatedLikesCount}_$isLiked'),
                      blog: blog.copyWith(likes_count: updatedLikesCount),
                      color: index % 2 == 0
                          ? AppPallete.gradient1
                          : AppPallete.gradient2,
                      isLiked: isLiked,
                      isBookmarked: isBookmarked,
                      onToggleBookmarked: () async {
                        await _toggleBookmark(blog.id);
                      },
                      onToggleLike: () => _toggleLike(blog.id, isLiked),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        //drawer: isOwnProfile
        //    ? const MyDrawer()
        //    : null, // Only show drawer if it's the user's own profile
      ),
    );
  }
}
