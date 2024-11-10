import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/topic.dart';
import 'package:blogapp/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllBlogTopics implements UseCase<List<Topic>, NoParams> {
  final BlogRepository blogRepository;

  GetAllBlogTopics(this.blogRepository);
  @override
  Future<Either<Failures, List<Topic>>> call(NoParams params) async {
    return await blogRepository.getAllBlogTopics();
  }
}
