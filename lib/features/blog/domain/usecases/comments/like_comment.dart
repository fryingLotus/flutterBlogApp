import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/repositories/comment_repository.dart';
import 'package:fpdart/fpdart.dart';

class LikeComment implements UseCase<bool, LikeCommentParams> {
  final CommentRepository commentRepository;

  LikeComment(this.commentRepository);
  @override
  Future<Either<Failures, bool>> call(LikeCommentParams params) async {
    return await commentRepository.likeComment(params.commentId);
  }
}

class LikeCommentParams {
  final String commentId;

  LikeCommentParams({required this.commentId});
}
