import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/features/auth/domain/entities/follower.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class FollowerRepository {
  Future<Either<Failures, Follower>> followUser({
    required String followedId,
    required String followerId,
  });
  Future<Either<Failures, void>> unfollowUser(String userIdToUnfollow);

  Future<Either<Failures, List<Follower>>> getFollowers(String userId);
  Future<Either<Failures, List<Follower>>> getFollowingList(String userId);
  Future<Either<Failures, Follower>> getFollowerDetail(String followerId);
}
