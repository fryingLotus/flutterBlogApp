import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class SearchBlogs implements UseCase<List<Blog>, SearchBlogsParams> {
  final BlogRepository blogRepository;

  SearchBlogs(this.blogRepository);
  @override
  Future<Either<Failures, List<Blog>>> call(SearchBlogsParams params) async {
    return await blogRepository.searchBlogs(title: params.title);
  }
}

class SearchBlogsParams {
  final String title;

  SearchBlogsParams({required this.title});
}
