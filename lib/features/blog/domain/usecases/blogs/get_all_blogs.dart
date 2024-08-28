import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllBlogs implements UseCase<List<Blog>, GetAllBlogsParams> {
  final BlogRepository blogRepository;

  GetAllBlogs(this.blogRepository);

  @override
  Future<Either<Failures, List<Blog>>> call(GetAllBlogsParams params) async {
    return await blogRepository.getAllBlogs(
        page: params.page, pageSize: params.pageSize);
  }
}

class GetAllBlogsParams {
  final int page;
  final int pageSize;

  GetAllBlogsParams({required this.page, required this.pageSize});
}
