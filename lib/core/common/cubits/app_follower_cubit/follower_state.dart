part of 'follower_cubit.dart';

@immutable
sealed class FollowUserState {}

final class FollowUserInitial extends FollowUserState {}

final class FollowUserLoading extends FollowUserState {}

final class FollowUserSuccess extends FollowUserState {
  final Follower follower;
  FollowUserSuccess(this.follower);
}

final class GetFollowerDetailSuccess extends FollowUserState {
  final Follower follower;
  GetFollowerDetailSuccess(this.follower);
}

final class FollowUserError extends FollowUserState {
  final String message;
  FollowUserError(this.message);
}

final class UnfollowUserSuccess extends FollowUserState {}

final class GetFollowersSuccess extends FollowUserState {
  final List<Follower> followers;
  GetFollowersSuccess(this.followers);
}
