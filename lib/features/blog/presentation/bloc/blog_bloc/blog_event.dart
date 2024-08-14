part of 'blog_bloc.dart';

@immutable
sealed class BlogEvent {}

final class BlogUpload extends BlogEvent {
  final String posterId;
  final String title;
  final String content;
  final File image;
  final List<String> topics;

  BlogUpload({
    required this.posterId,
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });
}

final class BlogUpdate extends BlogEvent {
  final String posterId;
  final String title;
  final String content;
  final File image;
  final List<String> topics;
  final String blogId;

  BlogUpdate(
      {required this.posterId,
      required this.title,
      required this.content,
      required this.image,
      required this.topics,
      required this.blogId});
}

final class BlogFetchAllBlogs extends BlogEvent {}

final class BlogFetchUserBlogs extends BlogEvent {}

final class BlogDelete extends BlogEvent {
  final String blogId;

  BlogDelete({required this.blogId});
}
