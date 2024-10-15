import 'dart:io';

import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/network/connection_checker.dart';
import 'package:blogapp/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:blogapp/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blogapp/features/blog/data/models/blog_model.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/entities/topic.dart';
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
  Future<Either<Failures, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<Topic> topics,
  }) async {
    try {
      // Check for internet connection first
      if (!await connectionChecker.isConnected) {
        return left(Failures('No Internet Connection!'));
      }

      // Initialize the blog model with a new ID, without the image URL for now
      BlogModel blogModel = BlogModel(
        id: const Uuid().v1(),
        posterId: posterId,
        title: title,
        content: content,
        imageUrl: '',
        topics: topics
            .map((topic) => topic.id)
            .toList(), // Extract IDs for insertion
        updatedAt: DateTime.now(),
      );

      // Upload the blog image and get the public URL
      final imageUrl = await blogRemoteDataSource.uploadBlogImage(
        image: image,
        blog: blogModel,
      );

      // Update the blog model with the image URL
      blogModel = blogModel.copyWith(imageUrl: imageUrl);

      // Upload the blog to the remote data source (Supabase in this case)
      final uploadedBlog = await blogRemoteDataSource.uploadBlog(blogModel);

      // Insert the relationship between the blog and each topic
      for (var topic in topics) {
        await blogRemoteDataSource.insertBlogTopic(
          blogId: uploadedBlog.id,
          topicId: topic.id, // Use the topic ID here
        );
      }

      // Return the successfully uploaded blog
      return right(uploadedBlog);
    } on ServerException catch (e) {
      // Handle server-related errors
      return left(Failures(e.message));
    } catch (e) {
      // Handle any other unexpected errors
      return left(Failures('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failures, List<Blog>>> getAllBlogs(
      {List<String>? topicIds, int page = 1, int pageSize = 10}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final blogs = blogLocalDataSource.loadBlogs();
        return right(blogs);
      }
      final blogs = await blogRemoteDataSource.getAllBlogs(
          topicIds: topicIds, page: page, pageSize: pageSize);
      blogLocalDataSource.uploadLocalBlog(blogs: blogs);
      return right(blogs);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Future<Either<Failures, List<Blog>>> getUserBlogs(String userId) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final blogs = blogLocalDataSource.loadBlogs();
        return right(blogs);
      }
      final blogs = await blogRemoteDataSource.getUserBlogs(userId);
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
    required List<Topic> topics,
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
        topics: topics.map((topic) => topic.id).toList(),
        updatedAt: DateTime.now(),
      );

      // Handle image upload if provided
      if (image != null) {
        final imageUrl = await blogRemoteDataSource.uploadBlogImage(
          image: image,
          blog: updatedBlog,
        );
        updatedBlog = updatedBlog.copyWith(imageUrl: imageUrl);
      } else if (currentImageUrl != null) {
        updatedBlog = updatedBlog.copyWith(imageUrl: currentImageUrl);
      }

      // Update the blog
      final updatedBlogModel =
          await blogRemoteDataSource.updateBlog(updatedBlog);

      // Handle topic associations
      await blogRemoteDataSource.updateBlogTopics(blogId, topics);

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

  @override
  Future<Either<Failures, List<Blog>>> getBlogsFromFollowedUsers(
      {int page = 1, int pageSize = 10}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final blogs = blogLocalDataSource.loadBlogs();
        return right(blogs);
      }
      final blogs = await blogRemoteDataSource.getBlogsFromFollowedUsers(
          page: page, pageSize: pageSize);
      blogLocalDataSource.uploadLocalBlog(blogs: blogs);
      return right(blogs);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Future<Either<Failures, List<Topic>>> getAllBlogTopics() async {
    try {
      final topics = await blogRemoteDataSource.getAllBlogTopics();
      return right(topics);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }
}
