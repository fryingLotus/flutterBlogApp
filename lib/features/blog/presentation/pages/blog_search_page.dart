import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/pages/follower_page.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/common/widgets/navigation_tile.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:blogapp/features/blog/presentation/bloc/blog_bloc/blog_bloc.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_card.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class BlogSearchPage extends StatefulWidget {
  const BlogSearchPage({super.key});
  @override
  State createState() => _BlogSearchPageState();
}

class _BlogSearchPageState extends State<BlogSearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  late TabController _tabController;
  late Box<bool> _likesBox;
  late Box<bool> _bookmarksBox;
  late String loggedInUserId;
  final Map<String, int> _localLikesCount = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeHiveBox();
    loggedInUserId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
  }

  Future<void> _initializeHiveBox() async {
    _likesBox = Hive.box<bool>(name: 'likesBox');
    _bookmarksBox = Hive.box<bool>(name: 'bookmarksBox');
  }

  void _performSearch() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      // Trigger both searches when search button is pressed
      context.read<AuthBloc>().add(AuthSearchUser(username: query));
      context.read<BlogBloc>().add(BlogSearch(title: query));
    }
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
  void dispose() {
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            BlogEditor(
              controller: searchController,
              hintText: 'Search users and blogs..',
              suffixIcon: const Icon(Icons.search),
              onSuffixIconPressed: _performSearch,
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Users'),
                Tab(text: 'Blogs'),
              ],
              labelColor: AppPallete.gradient2,
              unselectedLabelColor: AppPallete.greyColor,
              indicatorColor: AppPallete.whiteColor,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Users Tab
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthFailure) {
                        showSnackBar(context, state.message, isError: true);
                      }
                    },
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Loader();
                      } else if (state is AuthSearchSuccess) {
                        if (state.users.isEmpty) {
                          return const Center(
                            child: Text('No users found'),
                          );
                        }
                        return ListView.builder(
                          itemCount: state.users.length,
                          itemBuilder: (context, index) {
                            final user = state.users[index];
                            return NavigationTile(
                              title: user.name,
                              routeBuilder: (context) {
                                return FollowerPage(otherId: user.id);
                              },
                              profileImage: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(user.avatarUrl ?? ''),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: Text('Search for users and blogs'),
                      );
                    },
                  ),

                  // Blogs Tab
                  BlocConsumer<BlogBloc, BlogState>(
                    listener: (context, state) {
                      if (state is BlogFailure) {
                        showSnackBar(context, state.error, isError: true);
                      } else if (state is BlogLikeSuccess ||
                          state is BlogUnlikeSuccess) {
                        showSnackBar(context, "Success!");
                      }
                    },
                    builder: (context, state) {
                      if (state is BlogLoading) {
                        return const Loader();
                      } else if (state is BlogSearchSuccess) {
                        if (state.blogs.isEmpty) {
                          return const Center(
                            child: Text('No blogs found'),
                          );
                        }

                        return ListView.builder(
                          itemCount: state.blogs.length,
                          itemBuilder: (context, index) {
                            final blog = state.blogs[index];
                            final String uniqueKey =
                                '${loggedInUserId}_${blog.id}';
                            final isLiked =
                                _likesBox.get(uniqueKey, defaultValue: false) ??
                                    false;
                            final isBookmarked = _bookmarksBox.get(uniqueKey,
                                    defaultValue: false) ??
                                false;
                            final updatedLikesCount =
                                _localLikesCount[blog.id] ??
                                    blog.likes_count ??
                                    0;

                            return BlogCard(
                              key: ValueKey(
                                  '${blog.id}_${updatedLikesCount}_$isLiked'),
                              blog:
                                  blog.copyWith(likes_count: updatedLikesCount),
                              color: index % 2 == 0
                                  ? AppPallete.gradient1
                                  : AppPallete.gradient2,
                              isBookmarked: isBookmarked,
                              onToggleBookmarked: () async {
                                await _toggleBookmark(blog.id);
                              },
                              isLiked: isLiked,
                              onToggleLike: () => _toggleLike(blog.id, isLiked),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: Text('Search for users and blogs'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
