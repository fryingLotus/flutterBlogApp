import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/comment.dart';
import 'package:blogapp/features/blog/domain/repositories/comment_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCommentsForBlog
    implements UseCase<List<Comment>, GetCommentsForBlogParams> {
  final CommentRepository commentRepository;

  GetCommentsForBlog(this.commentRepository);

  @override
  Future<Either<Failures, List<Comment>>> call(
      GetCommentsForBlogParams params) async {
    return await commentRepository.getCommentsForBlog(blogId: params.blogId);
  }
}

class GetCommentsForBlogParams {
  final String blogId;

  GetCommentsForBlogParams({required this.blogId});
}
