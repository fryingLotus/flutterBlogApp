import 'dart:io';

import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/entities/topic.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class BlogRepository {
  Future<Either<Failures, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<Topic> topics,
  });
  Future<Either<Failures, List<Blog>>> getAllBlogs(
      {List<String>? topicIds, int page, int pageSize});

  Future<Either<Failures, List<Blog>>> getBlogsFromFollowedUsers(
      {List<String>? topicIds, int page, int pageSize});
  Future<Either<Failures, List<Blog>>> getUserBlogs(
      {List<String>? topicIds, required String userId});
  Future<Either<Failures, bool>> deleteBlog(String blogId);

  Future<Either<Failures, Blog>> updateBlog({
    required String blogId,
    File? image,
    required String title,
    required String content,
    required String posterId,
    required List<Topic> topics,
    String? currentImageUrl,
  });
  Future<Either<Failures, bool>> likeBlog(String blogId);
  Future<Either<Failures, bool>> unlikeBlog(String blogId);
  Future<Either<Failures, List<Topic>>> getAllBlogTopics();
  Future<Either<Failures, List<Blog>>> searchBlogs({required String title});
}
