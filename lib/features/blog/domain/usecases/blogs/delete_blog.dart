import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteBlog implements UseCase<bool, DeleteBlogParams> {
  final BlogRepository blogRepository;

  DeleteBlog(this.blogRepository);
  @override
  Future<Either<Failures, bool>> call(DeleteBlogParams params) async {
    return await blogRepository.deleteBlog(params.blogId);
  }
}

class DeleteBlogParams {
  final String blogId;

  DeleteBlogParams({required this.blogId});
}
