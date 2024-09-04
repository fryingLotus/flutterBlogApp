import 'package:blogapp/features/auth/domain/entities/follower.dart';
import 'package:blogapp/features/auth/domain/usecases/follower/follow_user.dart';
import 'package:blogapp/features/auth/domain/usecases/follower/get_follower_detail.dart';
import 'package:blogapp/features/auth/domain/usecases/follower/unfollow_user.dart';
import 'package:blogapp/features/auth/domain/usecases/follower/get_followers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'follower_state.dart';

class FollowUserCubit extends Cubit<FollowUserState> {
  final FollowUser followUserUseCase;
  final UnfollowUser unfollowUserUseCase;
  final GetFollowers getFollowersUseCase;
  final GetFollowerDetail getFollowerDetailUseCase; // Updated variable name

  FollowUserCubit(
    this.followUserUseCase,
    this.unfollowUserUseCase,
    this.getFollowersUseCase,
    this.getFollowerDetailUseCase, // Include in constructor
  ) : super(FollowUserInitial());

  Future<void> followUser(String followedId, String followerId) async {
    emit(FollowUserLoading());
    final result = await followUserUseCase(FollowUserParams(
      followedId: followedId,
      followerId: followerId,
    ));
    result.fold(
      (failure) => emit(FollowUserError(failure.message)),
      (follower) {
        print('Follow action response: ${follower.profileName}');
        emit(FollowUserSuccess(follower));
      },
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

  Future<void> getFollowerDetail(String followerId) async {
    // New method
    emit(FollowUserLoading());
    final result = await getFollowerDetailUseCase(GetFollowerDetailParams(
      followerId: followerId,
    ));
    result.fold(
      (failure) {
        print(failure.message.toString());
        emit(FollowUserError(failure.message));
      },
      (follower) {
        emit(GetFollowerDetailSuccess(follower));
      },
    );
  }
}
