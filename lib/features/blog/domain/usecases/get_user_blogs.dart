import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetUserBlogs implements UseCase<List<Blog>, NoParams> {
  final BlogRepository blogRepository;

  GetUserBlogs(this.blogRepository);

  @override
  Future<Either<Failures, List<Blog>>> call(NoParams params) async {
    return await blogRepository.getUserBlogs();
  }
}
