import 'package:blogapp/core/entities/user.dart';
import 'package:blogapp/features/auth/domain/entities/follower.dart';
import 'package:blogapp/features/auth/domain/usecases/follower/follow_user.dart';
import 'package:blogapp/features/auth/domain/usecases/follower/unfollow_user.dart';
import 'package:blogapp/features/auth/domain/usecases/follower/get_followers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'follower_state.dart';

class FollowUserCubit extends Cubit<FollowUserState> {
  final FollowUser followUserUseCase;
  final UnfollowUser unfollowUserUseCase;
  final GetFollowers getFollowersUseCase;

  FollowUserCubit(
    this.followUserUseCase,
    this.unfollowUserUseCase,
    this.getFollowersUseCase,
  ) : super(FollowUserInitial());

  Future<void> followUser(String followedId, String followerId) async {
    emit(FollowUserLoading());
    final result = await followUserUseCase(FollowUserParams(
      followedId: followedId,
      followerId: followerId,
    ));
    result.fold(
      (failure) => emit(FollowUserError(failure.message)),
      (follower) => emit(FollowUserSuccess(follower)),
    );
  }

  Future<void> unfollowUser(String userIdToUnfollow) async {
    emit(FollowUserLoading());
    final result = await unfollowUserUseCase(UnfollowUserParams(
      userIdToUnfollow: userIdToUnfollow,
    ));
    result.fold(
      (failure) => emit(FollowUserError(failure.message)),
      (_) => emit(UnfollowUserSuccess()),
    );
  }

  Future<void> getFollowers(String userId) async {
    emit(FollowUserLoading());
    final result =
        await getFollowersUseCase(GetFollowersParams(userId: userId));
    result.fold(
      (failure) => emit(FollowUserError(failure.message)),
      (followers) => emit(GetFollowersSuccess(followers)),
    );
  }
}

