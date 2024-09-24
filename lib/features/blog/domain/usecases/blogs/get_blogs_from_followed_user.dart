import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetBlogsFromFollowedUser
    implements UseCase<List<Blog>, GetBlogsFromFollowedUserParams> {
  final BlogRepository blogRepository;

  GetBlogsFromFollowedUser(this.blogRepository);
  @override
  Future<Either<Failures, List<Blog>>> call(
      GetBlogsFromFollowedUserParams params) async {
    return await blogRepository.getBlogsFromFollowedUsers(
        page: params.page, pageSize: params.pageSize);
  }
}

class GetBlogsFromFollowedUserParams {
  final int page;
  final int pageSize;

  GetBlogsFromFollowedUserParams({required this.page, required this.pageSize});
}