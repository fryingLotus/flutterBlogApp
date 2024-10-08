import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/network/connection_checker.dart';
import 'package:blogapp/features/blog/data/datasources/comment_remote_data_source.dart';
import 'package:blogapp/features/blog/data/models/comment_model.dart';
import 'package:blogapp/features/blog/domain/entities/comment.dart';
import 'package:blogapp/features/blog/domain/repositories/comment_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource commentRemoteDataSource;
  final ConnectionChecker connectionChecker;

  CommentRepositoryImpl(this.commentRemoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failures, bool>> deleteComment(String commentId) async {
    try {
      await commentRemoteDataSource.deleteComment(commentId);
      return right(true);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Future<Either<Failures, List<Comment>>> getCommentsForBlog({
    required String blogId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final comments = await commentRemoteDataSource.getCommentsForBlog(
        blogId,
        page: page,
        pageSize: pageSize,
      );
      return right(comments);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Future<Either<Failures, Comment>> uploadComment(
      {required String blogId,
      required String posterId,
      required String content,
      String? imageUrl}) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failures('No Internet Connection!'));
      }
      CommentModel commentModel = CommentModel(
          id: const Uuid().v1(),
          posterId: posterId,
          blogId: blogId,
          content: content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());

      final uploadedComment =
          await commentRemoteDataSource.uploadComment(commentModel);

      return right(uploadedComment);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Future<Either<Failures, Comment>> updateComment(
      {required String commentId, String? content}) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failures('No Internet Connection!'));
      }

      final existingCommentResult =
          await commentRemoteDataSource.getCommentById(commentId);

      final updatedComment = existingCommentResult.copyWith(
        content: content ?? existingCommentResult.content,
        updatedAt: DateTime.now(),
      );

      final result =
          await commentRemoteDataSource.updateComment(updatedComment);

      return right(result);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failures, Comment>> getCommentById(
      {required String commentId}) async {
    try {
      final comment = await commentRemoteDataSource.getCommentById(commentId);
      return right(comment);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Future<Either<Failures, bool>> likeComment(String commentId) async {
    try {
      await commentRemoteDataSource.likeComment(commentId);
      return right(true);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Future<Either<Failures, bool>> unlikeComment(String commentId) async {
    try {
      await commentRemoteDataSource.unlikeComment(commentId);
      return right(true);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }
}
