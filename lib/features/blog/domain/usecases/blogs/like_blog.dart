import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class LikeBlog implements UseCase<bool, LikeBlogParams> {
  final BlogRepository blogRepository;

  LikeBlog(this.blogRepository);
  @override
  Future<Either<Failures, bool>> call(LikeBlogParams params) async {
    return await blogRepository.likeBlog(params.blogId);
  }
}

class LikeBlogParams {
  final String blogId;

  LikeBlogParams({required this.blogId});
}
