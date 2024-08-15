import 'dart:io';

import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/delete_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/get_all_blogs.dart';
import 'package:blogapp/features/blog/domain/usecases/blogs/get_user_blogs.dart';
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
  BlogBloc({
    required UploadBlog uploadBlog,
    required GetAllBlogs getAllBlogs,
    required DeleteBlog deleteBlog,
    required GetUserBlogs getUserBlogs,
    required UpdateBlog updateBlog,
  })  : _uploadBlog = uploadBlog,
        _getAllBlogs = getAllBlogs,
        _getUserBlogs = getUserBlogs,
        _deleteBlog = deleteBlog,
        _updateBlog = updateBlog,
        super(BlogInitial()) {
    on<BlogEvent>((event, emit) => emit(BlogLoading()));
    on<BlogUpload>(_onBlogUpload);
    on<BlogFetchAllBlogs>(_onFetchAllBlog);
    on<BlogFetchUserBlogs>(_onFetchUserBlog);
    on<BlogDelete>(_onDeleteBlog);
    on<BlogUpdate>(_onUpdateBlog);
  }
  void _onBlogUpload(
    BlogUpload event,
    Emitter<BlogState> emit,
  ) async {
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
    final res = await _getAllBlogs(NoParams());
    res.fold(
      (l) => emit(BlogFailure(l.message)),
      (r) {
        // Print all fetched blogs for debugging
        print('Fetched All Blogs:');
        for (var blog in r) {
          print('Blog ID: ${blog.id}, Title: ${blog.title}');
        }
        emit(BlogsDisplaySuccess(r));
      },
    );
  }

  void _onFetchUserBlog(
      BlogFetchUserBlogs event, Emitter<BlogState> emit) async {
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

  void _onUpdateBlog(BlogUpdate event, Emitter<BlogState> emit) async {
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
