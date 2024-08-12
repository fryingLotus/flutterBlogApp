import 'dart:io';

import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:blogapp/features/blog/domain/usecases/get_user_blogs.dart';
import 'package:blogapp/features/blog/domain/usecases/upload_blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog _uploadBlog;
  final GetAllBlogs _getAllBlogs;
  final GetUserBlogs _getUserBlogs;
  BlogBloc(
      {required UploadBlog uploadBlog,
      required GetAllBlogs getAllBlogs,
      required GetUserBlogs getUserBlogs})
      : _uploadBlog = uploadBlog,
        _getAllBlogs = getAllBlogs,
        _getUserBlogs = getUserBlogs,
        super(BlogInitial()) {
    on<BlogEvent>((event, emit) => emit(BlogLoading()));
    on<BlogUpload>(_onBlogUpload);
    on<BlogFetchAllBlogs>(_onFetchAllBlog);
    on<BlogFetchUserBlogs>(_onFetchUserBlog);
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
      (r) => emit(BlogsDisplaySuccess(r)),
    );
  }

  void _onFetchUserBlog(
      BlogFetchUserBlogs event, Emitter<BlogState> emit) async {
    final res = await _getUserBlogs(NoParams());
    res.fold(
      (l) => emit(BlogFailure(l.message)),
      (r) => emit(UserBlogsDisplaySuccess(r)),
    );
  }
}
