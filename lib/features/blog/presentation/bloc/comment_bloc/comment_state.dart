part of 'comment_bloc.dart';

@immutable
sealed class CommentState {}

final class CommentInitial extends CommentState {}

final class CommentLoading extends CommentState {}

final class CommentFailure extends CommentState {
  final String error;
  CommentFailure(this.error);
}

final class CommentUploadSuccess extends CommentState {}

final class CommentsDisplaySuccess extends CommentState {
  final List<Comment> comments;
  final bool hasMore;

  CommentsDisplaySuccess({
    required this.comments,
    required this.hasMore,
  });
}

final class CommentLoadingMore extends CommentState {
  final List<Comment> comments;

  CommentLoadingMore({
    required this.comments,
  });
}

final class CommentDeleteSuccess extends CommentState {}

final class CommentUpdateSuccess extends CommentState {}
