part of 'comment_bloc.dart';

@immutable
sealed class CommentState {}

final class CommentInitial extends CommentState {}
final class CommentLoading extends CommentState{}

final class CommentFailure extends CommentState {
  final String error;
  CommentFailure(this.error);
}

final class CommentUploadSuccess extends CommentState {}