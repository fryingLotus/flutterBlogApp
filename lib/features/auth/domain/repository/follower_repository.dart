import 'package:blogapp/core/entities/user.dart';
import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/features/auth/domain/entities/follower.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class FollowerRepository {
  Future<Either<Failures, Follower>> followUser({
    required String followedId,
    required String followerId,
  });
  Future<Either<Failures, void>> unfollowUser(String userIdToUnfollow);

  Future<Either<Failures, List<User>>> getFollowers(String userId);
}
