part of 'blog_like_cubit.dart';

@immutable
sealed class BloglikecubitState {}

final class BloglikecubitInitial extends BloglikecubitState {}

final class BlogLikeInProgress extends BloglikecubitState {}

final class BlogLiked extends BloglikecubitState {
  final bool isLiked;
  BlogLiked({required this.isLiked});
}

final class BlogLikeError extends BloglikecubitState {
  final String message;
  BlogLikeError({required this.message});
}
