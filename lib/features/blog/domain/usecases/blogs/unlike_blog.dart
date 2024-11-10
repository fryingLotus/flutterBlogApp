import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class UnlikeBlog implements UseCase<bool, UnlikeBlogParams> {
  final BlogRepository blogRepository;

  UnlikeBlog(this.blogRepository);
  @override
  Future<Either<Failures, bool>> call(UnlikeBlogParams params) async {
    return await blogRepository.unlikeBlog(params.blogId);
  }
}

class UnlikeBlogParams {
  final String blogId;

  UnlikeBlogParams({required this.blogId});
}
