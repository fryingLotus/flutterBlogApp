import 'dart:io';

import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class BlogRepository {
  Future<Either<Failures, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  });
  Future<Either<Failures, List<Blog>>> getAllBlogs();

  Future<Either<Failures, List<Blog>>> getUserBlogs();

  Future<Either<Failures, bool>> deleteBlog(String blogId);
  Future<Either<Failures, Blog>> updateBlog({
    required String blogId,
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  });
}
