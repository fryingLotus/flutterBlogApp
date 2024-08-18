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
  final int page;
  final int pageSize;

  CommentFetchAllForBlog({
    required this.blogId,
    this.page = 1,
    this.pageSize = 10,
  });
}

final class CommentDelete extends CommentEvent {
  final String commentId;

  CommentDelete({required this.commentId});
}

final class CommentUpdate extends CommentEvent {
  final String commentId;
  final String content;

  CommentUpdate({required this.commentId, required this.content});
}
