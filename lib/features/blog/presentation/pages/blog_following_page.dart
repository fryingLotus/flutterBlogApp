import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/features/blog/presentation/widgets/blog_card.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/presentation/bloc/blog_bloc/blog_bloc.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:hive/hive.dart';

class BlogFollowingPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const BlogFollowingPage());
  const BlogFollowingPage({super.key});

  @override
  State<BlogFollowingPage> createState() => _BlogFollowingPageState();
}

class _BlogFollowingPageState extends State<BlogFollowingPage> {
  static const int _pageSize = 10;
  late Box<bool> _likesBox;
  final PagingController<int, Blog> _followedBlogsPagingController =
      PagingController(firstPageKey: 1);
  final Set<String> _loadedFollowedBlogIds = {};

  @override
  void initState() {
    super.initState();
    _openLikesBox();
    _followedBlogsPagingController.addPageRequestListener((pageKey) {
      _fetchFollowedBlogsPage(pageKey);
    });
  }

  Future<void> _openLikesBox() async {
    _likesBox = Hive.box<bool>(name: 'likesBox');
  }

  Future<void> _fetchFollowedBlogsPage(int pageKey) async {
    try {
      final bloc = context.read<BlogBloc>();
      bloc.add(BlogFetchUserFollowBlogs(page: pageKey, pageSize: _pageSize));

      await for (final state in bloc.stream) {
        if (state is BlogsDisplayUserFollowSuccess) {
          if (!mounted) return;

          final newItems = state.blogs;
          final filteredItems = newItems
              .where((blog) => !_loadedFollowedBlogIds.contains(blog.id))
              .toList();

          _loadedFollowedBlogIds.addAll(filteredItems.map((blog) => blog.id));

          final isLastPage = filteredItems.length < _pageSize;
          if (isLastPage) {
            _followedBlogsPagingController.appendLastPage(filteredItems);
          } else {
            final nextPageKey = pageKey + 1;
            _followedBlogsPagingController.appendPage(
                filteredItems, nextPageKey);
          }
          break;
        } else if (state is BlogFailure) {
          if (mounted) {
            _followedBlogsPagingController.error = state.error;
          }
          break;
        }
      }
    } catch (error) {
      if (mounted) {
        _followedBlogsPagingController.error = error;
      }
    }
  }

  @override
  void dispose() {
    _followedBlogsPagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following Blogs'),
      ),
      body: PagedListView<int, Blog>(
        pagingController: _followedBlogsPagingController,
        builderDelegate: PagedChildBuilderDelegate<Blog>(
          itemBuilder: (context, blog, index) {
            final String userId =
                (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
            final String uniqueKey = '${userId}_${blog.id}';

            final isLiked =
                _likesBox.get(uniqueKey, defaultValue: false) ?? false;
            final updatedLikesCount =
                isLiked ? (blog.likes_count ?? 0) + 1 : (blog.likes_count ?? 0);

            return BlogCard(
              key: ValueKey(blog.id),
              blog: blog.copyWith(likes_count: updatedLikesCount),
              color:
                  index % 2 == 0 ? AppPallete.gradient1 : AppPallete.gradient2,
              isLiked: isLiked,
              onToggleLike: () async {
                // Implement toggle like functionality if necessary
              },
            );
          },
        ),
      ),
    );
  }
}

