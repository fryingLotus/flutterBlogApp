import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
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
import 'package:hive/hive.dart';

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
  late String loggedInUserId;

  @override
  void initState() {
    super.initState();
    _initializeLikesBox();
    _fetchUserBlogs();
    // Get the logged-in user's ID
    loggedInUserId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
  }

  Future<void> _initializeLikesBox() async {
    _likesBox = Hive.box<bool>(name: 'likesBox');
  }

  Future<void> _fetchUserBlogs() async {
    context.read<BlogBloc>().add(BlogFetchUserBlogs(userId: widget.userId));
  }

  Future<void> _toggleLike(String blogId, bool isLiked) async {
    try {
      final String uniqueKey = '${loggedInUserId}_$blogId';

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
                ), // Show back button if viewing another user's blogs
          actions: isOwnProfile
              ? [
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, AddNewBlogPage.route());
                    },
                    icon: const Icon(CupertinoIcons.add_circled),
                  ),
                ]
              : null, // No add button if viewing other user's blogs
        ),
        body: BlocConsumer<BlogBloc, BlogState>(
          listener: (context, state) {
            if (state is BlogFailure) {
              showSnackBar(context, state.error, isError: true);
            } else if (state is BlogLikeSuccess || state is BlogUnlikeSuccess) {
              _fetchUserBlogs(); // Refresh the list to reflect like/unlike changes
              showSnackBar(context, "Success!");
            }
          },
          builder: (context, state) {
            if (state is BlogLoading) {
              return const Loader();
            }
            if (state is UserBlogsDisplaySuccess) {
              return RefreshIndicator(
                onRefresh: _fetchUserBlogs,
                child: ListView.builder(
                  itemCount: state.userBlogs.length,
                  itemBuilder: (context, index) {
                    final blog = state.userBlogs[index];

                    final String uniqueKey = '${loggedInUserId}_${blog.id}';
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
              );
            }
            return const SizedBox.shrink();
          },
        ),
        drawer: isOwnProfile
            ? const MyDrawer()
            : null, // Only show drawer if it's the user's own profile
      ),
    );
  }
}
