import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/comment.dart';
import 'package:blogapp/features/blog/domain/repositories/comment_repository.dart';
import 'package:fpdart/fpdart.dart';

class UploadComment implements UseCase<Comment, UploadCommentParams> {
  final CommentRepository commentRepository;

  UploadComment(this.commentRepository);
  @override
  Future<Either<Failures, Comment>> call(UploadCommentParams params) async {
    return await commentRepository.uploadComment(
        blogId: params.blogId,
        posterId: params.posterId,
        content: params.content);
  }
}

class UploadCommentParams {
  final String posterId;
  final String blogId;
  final String content;

  UploadCommentParams(
      {required this.posterId, required this.blogId, required this.content});
}
