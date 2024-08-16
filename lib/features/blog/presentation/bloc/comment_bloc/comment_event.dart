part of 'comment_bloc.dart';

@immutable
sealed class CommentEvent {}

final class CommentUpload extends CommentEvent {
  final String posterId;
  final String content;
  final String blogId;

  CommentUpload(
      {required this.posterId, required this.content, required this.blogId});
}

final class CommentFetchAllForBlog extends CommentEvent {
  final String blogId;

  CommentFetchAllForBlog({required this.blogId});
}

final class CommentDelete extends CommentEvent {
  final String commentId;

  CommentDelete({required this.commentId});
}
