import 'dart:io';

import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/entities/topic.dart';
import 'package:blogapp/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateBlog implements UseCase<Blog, UpdateBlogParams> {
  final BlogRepository blogRepository;

  UpdateBlog(this.blogRepository);

  @override
  Future<Either<Failures, Blog>> call(UpdateBlogParams params) async {
    return await blogRepository.updateBlog(
      posterId: params.posterId,
      blogId: params.blogId,
      image: params.image,
      title: params.title,
      content: params.content,
      topics: params.topics,
      currentImageUrl: params.currentImageUrl,
    );
  }
}

class UpdateBlogParams {
  final String blogId;
  final String title;
  final String posterId;
  final String content;
  final File? image;
  final List<Topic> topics;
  final String? currentImageUrl;

  UpdateBlogParams({
    required this.blogId,
    required this.title,
    required this.posterId,
    required this.content,
    this.image,
    required this.topics,
    this.currentImageUrl,
  });
}
