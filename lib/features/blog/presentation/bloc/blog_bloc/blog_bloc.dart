import 'dart:io';

import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/delete_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/get_all_blogs.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/get_user_blogs.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/like_blog.dart';
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
  List<Blog>? _blogs;
  BlogBloc({
    required UploadBlog uploadBlog,
    required GetAllBlogs getAllBlogs,
    required DeleteBlog deleteBlog,
    required GetUserBlogs getUserBlogs,
    required UpdateBlog updateBlog,
    required LikeBlog likeBlog,
    required UnlikeBlog unlikeBlog,
  })  : _uploadBlog = uploadBlog,
        _getAllBlogs = getAllBlogs,
        _getUserBlogs = getUserBlogs,
        _deleteBlog = deleteBlog,
        _likeBlog = likeBlog,
        _updateBlog = updateBlog,
        _unlikeBlog = unlikeBlog,
        super(BlogInitial()) {
    //on<BlogEvent>((event, emit) => emit(BlogLoading()));
    on<BlogUpload>(_onBlogUpload);
    on<BlogFetchAllBlogs>(_onFetchAllBlog);
    on<BlogFetchUserBlogs>(_onFetchUserBlog);
    on<BlogDelete>(_onDeleteBlog);
    on<BlogUpdate>(_onUpdateBlog);
    on<BlogLike>(_onLikeBlog);
    on<BlogUnlike>(_onUnlikeBlog);
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
    if (state is BlogsDisplaySuccess) {
      final currentBlogs = (state as BlogsDisplaySuccess).blogs;
      emit(BlogPaginationLoading());

      final res = await _getAllBlogs(
          GetAllBlogsParams(page: event.page, pageSize: event.pageSize));
      res.fold(
        (l) => emit(BlogFailure(l.message)),
        (r) {
          final isLastPage = r.length < event.pageSize;
          final updatedBlogs = List<Blog>.from(currentBlogs)..addAll(r);
          _blogs = updatedBlogs;
          emit(BlogsDisplaySuccess(updatedBlogs, isLastPage: isLastPage));
        },
      );
    } else {
      emit(BlogLoading());
      final res = await _getAllBlogs(
          GetAllBlogsParams(page: event.page, pageSize: event.pageSize));
      res.fold(
        (l) => emit(BlogFailure(l.message)),
        (r) {
          final isLastPage = r.length < event.pageSize;
          _blogs = r;
          emit(BlogsDisplaySuccess(r, isLastPage: isLastPage));
        },
      );
    }
  }

  void _onFetchUserBlog(
      BlogFetchUserBlogs event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    final res = await _getUserBlogs(NoParams());
    res.fold(
      (l) => emit(BlogFailure(l.message)),
      (r) {
        // Print all user-owned blogs for debugging
        print('Fetched User Blogs:');
        for (var blog in r) {
          print('Blog ID: ${blog.id}, Title: ${blog.title}');
        }
        emit(UserBlogsDisplaySuccess(r));
      },
    );
  }

  void _onDeleteBlog(BlogDelete event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    print('Deleting blog with ID: ${event.blogId}');

    final res = await _deleteBlog(DeleteBlogParams(blogId: event.blogId));
    res.fold(
      (l) {
        print('Delete failed: ${l.message}');
        emit(BlogFailure(l.message));
      },
      (r) {
        print('Blog deleted successfully.');
        emit(BlogDeleteSuccess());
      },
    );
  }

  void _onLikeBlog(BlogLike event, Emitter<BlogState> emit) async {
    final res = await _likeBlog(LikeBlogParams(blogId: event.blogId));
    res.fold(
      (l) {
        emit(BlogFailure(l.message));
      },
      (r) {
        _updateLikeStatus(event.blogId, true);
        emit(BlogLikeSuccess(event.blogId));
        emit(BlogsDisplaySuccess(
            _blogs!)); // Re-emit the blogs with updated like status
      },
    );
  }

  void _onUnlikeBlog(BlogUnlike event, Emitter<BlogState> emit) async {
    final res = await _unlikeBlog(UnlikeBlogParams(blogId: event.blogId));
    res.fold(
      (l) {
        emit(BlogFailure(l.message));
      },
      (r) {
        _updateLikeStatus(event.blogId, false);
        emit(BlogUnlikeSuccess(event.blogId));
        emit(BlogsDisplaySuccess(
            _blogs!)); // Re-emit the blogs with updated unlike status
      },
    );
  }

  // Helper method to update the like status of a blog locally
  void _updateLikeStatus(String blogId, bool isLiked) {
    _blogs = _blogs?.map((blog) {
      if (blog.id == blogId) {
        return blog.copyWith(
            isLiked: isLiked); // Ensure your Blog entity has a copyWith method
      }
      return blog;
    }).toList();
  }

  void _onUpdateBlog(BlogUpdate event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    // Log the incoming event details
    print('Updating blog: ${event.blogId}');
    print('Poster ID: ${event.posterId}');
    print('Title: ${event.title}');
    print('Content: ${event.content}');
    print('Topics: ${event.topics}');

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
        print('Update failed: ${l.message}'); // Log failure message
        emit(BlogFailure(l.message));
      },
      (r) {
        print(
            'Update successful: ${r.id}'); // Log success message (or any other relevant info)
        emit(BlogUpdateSuccess());
      },
    );
  }
}
