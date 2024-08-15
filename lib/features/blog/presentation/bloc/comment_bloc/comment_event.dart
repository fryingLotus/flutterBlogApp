part of 'comment_bloc.dart';

@immutable
sealed class CommentEvent {}

final class CommentUpload extends CommentEvent {
  final String posterId;
  final String content;
  final String blogId;

  CommentUpload({required this.posterId, required this.content, required this.blogId});
}
