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
  Future<Either<Failures, bool>> deleteComment(String commentId) {
    // TODO: implement deleteComment
    throw UnimplementedError();
  }

  @override
  Future<Either<Failures, List<Comment>>> getCommentsForBlog(String blogId) {
    // TODO: implement getCommentsForBlog
    throw UnimplementedError();
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
      {required String commentId, String? content}) {
    // TODO: implement updateComment
    throw UnimplementedError();
  }
}
