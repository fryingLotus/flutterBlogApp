import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/features/blog/domain/entities/comment.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class CommentRepository {
  Future<Either<Failures, Comment>> uploadComment({
    required String blogId,
    required String posterId,
    required String content,
  });

  Future<Either<Failures, List<Comment>>> getCommentsForBlog(
      {required String blogId});

  Future<Either<Failures, bool>> deleteComment(String commentId);

  Future<Either<Failures, Comment>> updateComment({
    required String commentId,
    String? content,
  });
  Future<Either<Failures, Comment>> getCommentById({
    required String commentId,
  });
}
