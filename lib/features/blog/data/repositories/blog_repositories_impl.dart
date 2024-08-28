import 'dart:io';

import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/network/connection_checker.dart';
import 'package:blogapp/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:blogapp/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blogapp/features/blog/data/models/blog_model.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class BlogRepositoriesImpl implements BlogRepository {
  final BlogRemoteDataSource blogRemoteDataSource;
  final BlogLocalDataSource blogLocalDataSource;
  final ConnectionChecker connectionChecker;
  BlogRepositoriesImpl(this.blogRemoteDataSource, this.blogLocalDataSource,
      this.connectionChecker);
  @override
  Future<Either<Failures, Blog>> uploadBlog(
      {required File image,
      required String title,
      required String content,
      required String posterId,
      required List<String> topics}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failures('No Internect Connection!'));
      }
      BlogModel blogModel = BlogModel(
          id: const Uuid().v1(),
          posterId: posterId,
          title: title,
          content: content,
          imageUrl: '',
          topics: topics,
          updatedAt: DateTime.now());

      final imageUrl = await blogRemoteDataSource.uploadBlogImage(
          image: image, blog: blogModel);
      blogModel = blogModel.copyWith(imageUrl: imageUrl);

      final uploadedBlog = await blogRemoteDataSource.uploadBlog(blogModel);

      return right(uploadedBlog);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Future<Either<Failures, List<Blog>>> getAllBlogs(
      {int page = 1, int pageSize = 10}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final blogs = blogLocalDataSource.loadBlogs();
        return right(blogs);
      }
      final blogs = await blogRemoteDataSource.getAllBlogs(
          page: page, pageSize: pageSize);
      blogLocalDataSource.uploadLocalBlog(blogs: blogs);
      return right(blogs);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Future<Either<Failures, List<Blog>>> getUserBlogs() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final blogs = blogLocalDataSource.loadBlogs();
        return right(blogs);
      }
      final blogs = await blogRemoteDataSource.getUserBlogs();
      blogLocalDataSource.uploadLocalBlog(blogs: blogs);
      return right(blogs);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Future<Either<Failures, bool>> deleteBlog(String blogId) async {
    try {
      await blogRemoteDataSource.deleteBlog(blogId);
      return right(true);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures('An unknown error occurred.'));
    }
  }

  @override
  Future<Either<Failures, Blog>> updateBlog({
    required String blogId,
    File? image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
    String? currentImageUrl,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failures('No Internet Connection!'));
      }

      BlogModel updatedBlog = BlogModel(
        id: blogId,
        posterId: posterId,
        title: title,
        content: content,
        imageUrl: currentImageUrl ?? '',
        topics: topics,
        updatedAt: DateTime.now(),
      );

      // If an image is provided, upload it and get the new URL
      if (image != null) {
        final imageUrl = await blogRemoteDataSource.uploadBlogImage(
          image: image,
          blog: updatedBlog,
        );
        updatedBlog = updatedBlog.copyWith(imageUrl: imageUrl);
      } else if (currentImageUrl != null) {
        // If no new image is provided, keep the current URL
        updatedBlog = updatedBlog.copyWith(imageUrl: currentImageUrl);
      }

      final updatedBlogModel =
          await blogRemoteDataSource.updateBlog(updatedBlog);
      return right(updatedBlogModel);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures('An unknown error occurred.'));
    }
  }

  @override
  Future<Either<Failures, bool>> likeBlog(String blogId) async {
    try {
      await blogRemoteDataSource.likeBlog(blogId);
      return right(true);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures('An unknown error occurred.'));
    }
  }

  @override
  Future<Either<Failures, bool>> unlikeBlog(String blogId) async {
    try {
      await blogRemoteDataSource.unlikeBlog(blogId);
      return right(true);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures('An unknown error occurred.'));
    }
  }
}
