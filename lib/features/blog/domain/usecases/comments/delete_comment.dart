import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/repositories/comment_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteComment implements UseCase<bool, DeleteCommentParams> {
  final CommentRepository commentRepository;

  DeleteComment(this.commentRepository);

  @override
  Future<Either<Failures, bool>> call(DeleteCommentParams params) async {
    return await commentRepository.deleteComment(params.commentId);
  }
}

class DeleteCommentParams {
  final String commentId;

  DeleteCommentParams({required this.commentId});
}
