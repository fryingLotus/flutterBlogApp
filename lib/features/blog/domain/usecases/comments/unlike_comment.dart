import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/repositories/comment_repository.dart';
import 'package:fpdart/fpdart.dart';

class UnlikeComment implements UseCase<bool, UnlikeCommentParams> {
  final CommentRepository commentRepository;

  UnlikeComment(this.commentRepository);
  @override
  Future<Either<Failures, bool>> call(UnlikeCommentParams params) async {
    return await commentRepository.unlikeComment(params.commentId);
  }
}

class UnlikeCommentParams {
  final String commentId;

  UnlikeCommentParams({required this.commentId});
}
