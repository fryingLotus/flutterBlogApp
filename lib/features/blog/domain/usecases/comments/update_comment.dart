import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/comment.dart';
import 'package:blogapp/features/blog/domain/repositories/comment_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateComment implements UseCase<Comment, UpdateCommentParams> {
  final CommentRepository commentRepository;

  UpdateComment(this.commentRepository);
  @override
  Future<Either<Failures, Comment>> call(UpdateCommentParams params) async {
    return await commentRepository.updateComment(
        commentId: params.commentId, content: params.content);
  }
}

class UpdateCommentParams {
  final String commentId;
  final String content;

  UpdateCommentParams({required this.commentId, required this.content});
}
