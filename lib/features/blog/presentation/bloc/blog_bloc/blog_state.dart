part of 'blog_bloc.dart';

@immutable
sealed class BlogState {}

final class BlogInitial extends BlogState {}

final class BlogLoading extends BlogState {}

final class BlogFailure extends BlogState {
  final String error;
  BlogFailure(this.error);
}

final class BlogUploadSuccess extends BlogState {}

final class BlogUpdateSuccess extends BlogState {}

final class BlogDeleteSuccess extends BlogState {}

final class BlogPaginationLoading extends BlogState {}

final class BlogLikeSuccess extends BlogState {
  final String blogId;

  BlogLikeSuccess(this.blogId);
}

final class BlogUnlikeSuccess extends BlogState {
  final String blogId;

  BlogUnlikeSuccess(this.blogId);
}

final class BlogsDisplaySuccess extends BlogState {
  final List<Blog> blogs;
  final bool isLastPage;

  BlogsDisplaySuccess(this.blogs, {this.isLastPage = false});
}

final class BlogsDisplayUserFollowSuccess extends BlogState {
  final List<Blog> blogs;
  final bool isLastPage;

  BlogsDisplayUserFollowSuccess(this.blogs, {this.isLastPage = false});
}

final class UserBlogsDisplaySuccess extends BlogState {
  final List<Blog> userBlogs;

  UserBlogsDisplaySuccess(this.userBlogs);
}

final class BlogTopicsDisplaySuccess extends BlogState {
  final List<Topic> topics;

  BlogTopicsDisplaySuccess(this.topics);
}
