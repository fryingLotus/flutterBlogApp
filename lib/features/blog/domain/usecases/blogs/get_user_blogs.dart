import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetUserBlogs implements UseCase<List<Blog>, GetUserBlogsParams> {
  final BlogRepository blogRepository;

  GetUserBlogs(this.blogRepository);

  @override
  Future<Either<Failures, List<Blog>>> call(GetUserBlogsParams params) async {
    return await blogRepository.getUserBlogs(
        userId: params.userId, topicIds: params.topicIds);
  }
}

class GetUserBlogsParams {
  final String userId;
  final List<String>? topicIds;

  GetUserBlogsParams({this.topicIds, required this.userId});
}
