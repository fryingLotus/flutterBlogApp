import 'dart:io';

import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/entities/topic.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/delete_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/get_all_blog_topics.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/get_all_blogs.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/get_blogs_from_followed_user.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/get_user_blogs.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/like_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/search_blogs.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/unlike_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/update_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/upload_blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog _uploadBlog;
  final GetAllBlogs _getAllBlogs;
  final GetUserBlogs _getUserBlogs;
  final DeleteBlog _deleteBlog;
  final UpdateBlog _updateBlog;
  final LikeBlog _likeBlog;
  final UnlikeBlog _unlikeBlog;
  final GetBlogsFromFollowedUser _getBlogsFromFollowedUser;
  final GetAllBlogTopics _getAllBlogTopics;
  final SearchBlogs _searchBlogs;
  List<Blog>? _blogs;
  BlogBloc(
      {required UploadBlog uploadBlog,
      required GetAllBlogs getAllBlogs,
      required DeleteBlog deleteBlog,
      required GetUserBlogs getUserBlogs,
      required UpdateBlog updateBlog,
      required LikeBlog likeBlog,
      required UnlikeBlog unlikeBlog,
      required GetAllBlogTopics getAllBlogTopics,
      required SearchBlogs searchBlogs,
      required GetBlogsFromFollowedUser getBlogsFromFollowedUser})
      : _uploadBlog = uploadBlog,
        _getAllBlogs = getAllBlogs,
        _getUserBlogs = getUserBlogs,
        _deleteBlog = deleteBlog,
        _likeBlog = likeBlog,
        _updateBlog = updateBlog,
        _unlikeBlog = unlikeBlog,
        _getBlogsFromFollowedUser = getBlogsFromFollowedUser,
        _getAllBlogTopics = getAllBlogTopics,
        _searchBlogs = searchBlogs,
        super(BlogInitial()) {
    //on<BlogEvent>((event, emit) => emit(BlogLoading()));
    on<BlogUpload>(_onBlogUpload);
    on<BlogFetchAllBlogs>(_onFetchAllBlog);
    on<BlogFetchUserBlogs>(_onFetchUserBlog);
    on<BlogFetchUserFollowBlogs>(_onBlogFetchUserFollowBlogs);
    on<BlogDelete>(_onDeleteBlog);
    on<BlogUpdate>(_onUpdateBlog);
    on<BlogLike>(_onLikeBlog);
    on<BlogUnlike>(_onUnlikeBlog);
    on<BlogFetchAllBlogTopics>(_onFetchBlogTopics);
    on<BlogSearch>(_onSearchBlogs);
  }
  void _onBlogUpload(
    BlogUpload event,
    Emitter<BlogState> emit,
  ) async {
    emit(BlogLoading());
    final res = await _uploadBlog(
      UploadBlogParams(
        posterId: event.posterId,
        title: event.title,
        content: event.content,
        image: event.image,
        topics: event.topics,
      ),
    );

    res.fold(
      (l) {
        emit(BlogFailure(l.message));
      },
      (r) {
        emit(BlogUploadSuccess());
      },
    );
  }

  void _onFetchAllBlog(BlogFetchAllBlogs event, Emitter<BlogState> emit) async {
    try {
      final res = await _getAllBlogs(GetAllBlogsParams(
        topicIds: event.topicIds ?? [],
        page: event.page,
        pageSize: event.pageSize,
      ));

      res.fold(
        (l) {
          // Log error
          emit(BlogFailure(l.message)); // Emit failure state
        },
        (r) {
          // Log the blogs
          final isLastPage = r.length < event.pageSize;
          emit(BlogsDisplaySuccess(r,
              isLastPage: isLastPage)); // Emit success state
        },
      );
    } catch (e) {
      // Log exceptions
      emit(BlogFailure(
          e.toString())); // Emit failure state if an exception occurs
    }
  }

  void _onBlogFetchUserFollowBlogs(
      BlogFetchUserFollowBlogs event, Emitter<BlogState> emit) async {
    print(
        "Fetching blogs from followed users. Page: ${event.page}, PageSize: ${event.pageSize}, TopicIds: ${event.topicIds}");
    try {
      final res = await _getBlogsFromFollowedUser(
        GetBlogsFromFollowedUserParams(
            topicIds: event.topicIds ?? [],
            page: event.page,
            pageSize: event.pageSize),
      );
      res.fold(
        (l) {
          print("Error fetching blogs from followed users: ${l.message}");
          emit(BlogFailure(l.message));
        },
        (r) {
          print("Fetched ${r.length} blogs from followed users");
          final isLastPage = r.length < event.pageSize;
          emit(BlogsDisplayUserFollowSuccess(r, isLastPage: isLastPage));
        },
      );
    } catch (e) {
      print("Exception in _onBlogFetchUserFollowBlogs: $e");
      emit(BlogFailure(e.toString()));
    }
  }

  void _onFetchUserBlog(
      BlogFetchUserBlogs event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    final res = await _getUserBlogs(GetUserBlogsParams(
        userId: event.userId, topicIds: event.topicIds ?? []));
    res.fold(
      (l) => emit(BlogFailure(l.message)),
      (r) {
        // Print all user-owned blogs for debugging
        for (var blog in r) {}
        emit(UserBlogsDisplaySuccess(r));
      },
    );
  }

  void _onDeleteBlog(BlogDelete event, Emitter<BlogState> emit) async {
    emit(BlogLoading());

    final res = await _deleteBlog(DeleteBlogParams(blogId: event.blogId));
    res.fold(
      (l) {
        emit(BlogFailure(l.message));
      },
      (r) {
        emit(BlogDeleteSuccess());
      },
    );
  }

  void _onLikeBlog(BlogLike event, Emitter<BlogState> emit) async {
    final res = await _likeBlog(LikeBlogParams(blogId: event.blogId));

    res.fold(
      (l) => emit(BlogFailure(l.message)),
      (r) => emit(BlogLikeSuccess(event.blogId)),
    );
  }

  void _onUnlikeBlog(BlogUnlike event, Emitter<BlogState> emit) async {
    final res = await _unlikeBlog(UnlikeBlogParams(blogId: event.blogId));

    res.fold(
      (l) => emit(BlogFailure(l.message)),
      (r) => emit(BlogUnlikeSuccess(event.blogId)),
    );
  }

  // Helper method to update the like status of a blog locally
  void _updateLikeStatus(String blogId, bool isLiked) {
    _blogs = _blogs?.map((blog) {
      if (blog.id == blogId) {
        return blog.copyWith(
          isLiked: isLiked,
          likes_count: isLiked
              ? (blog.likes_count ?? 0) + 1
              : (blog.likes_count ?? 0) - 1,
        );
      }
      return blog;
    }).toList();
  }

  void _onUpdateBlog(BlogUpdate event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    // Log the incoming event details

    // Call the update blog method
    final res = await _updateBlog(
      UpdateBlogParams(
        posterId: event.posterId,
        blogId: event.blogId,
        title: event.title,
        content: event.content,
        image: event.image, // Pass the image
        topics: event.topics,
        currentImageUrl: event.currentImageUrl, // Pass the current image URL
      ),
    );

    // Log the result of the update operation
    res.fold(
      (l) {
        // Log failure message
        emit(BlogFailure(l.message));
      },
      (r) {
        // Log success message (or any other relevant info)
        emit(BlogUpdateSuccess());
      },
    );
  }

  void _onFetchBlogTopics(
      BlogFetchAllBlogTopics event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    final res = await _getAllBlogTopics(NoParams());
    res.fold(
      (l) {
        emit(BlogFailure(l.message));
      },
      (r) {
        emit(BlogTopicsDisplaySuccess(r));
      },
    );
  }

  void _onSearchBlogs(BlogSearch event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    final res = await _searchBlogs(SearchBlogsParams(title: event.title));
    res.fold(
      (l) {
        emit(BlogFailure(l.message));
      },
      (r) {
        emit(BlogSearchSuccess(r));
      },
    );
  }
}
