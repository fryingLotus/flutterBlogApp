import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/blog/domain/entities/blog.dart';
import 'package:blogapp/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetBookmarkedBlogs
    implements UseCase<List<Blog>, GetBookmarkedBlogsParams> {
  final BlogRepository blogRepository;

  GetBookmarkedBlogs(this.blogRepository);
  @override
  Future<Either<Failures, List<Blog>>> call(
      GetBookmarkedBlogsParams params) async {
    return await blogRepository.fetchBlogsByBookmarks(
        blogIds: params.blogIds, topicIds: params.topicIds);
  }
}

class GetBookmarkedBlogsParams {
  final List<String>? topicIds;
  final List<String> blogIds;

  GetBookmarkedBlogsParams({this.topicIds, required this.blogIds});
}
