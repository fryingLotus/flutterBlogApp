import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/network/connection_checker.dart';
import 'package:blogapp/features/auth/data/datasources/follower_remote_data_source.dart';
import 'package:blogapp/features/auth/data/models/follower_model.dart';
import 'package:blogapp/features/auth/domain/entities/follower.dart';
import 'package:blogapp/features/auth/domain/repository/follower_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class FollowerRepositoryImpl implements FollowerRepository {
  final FollowerRemoteDataSource followerRemoteDataSource;
  final ConnectionChecker connectionChecker;

  FollowerRepositoryImpl(this.followerRemoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failures, Follower>> followUser({
    required String followedId,
    required String followerId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failures('No Internet Connection!'));
      }

      final followerModel = FollowerModel(
        id: const Uuid().v1(),
        followerId: followerId,
        followedId: followedId,
        followedAt: DateTime.now(),
      );

      final followingUser =
          await followerRemoteDataSource.followUser(followerModel);
      return right(followingUser);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures(e.toString()));
    }
  }

  @override
  Future<Either<Failures, List<Follower>>> getFollowers(String userId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failures('No Internet Connection!'));
      }

      final followers = await followerRemoteDataSource.getFollowers(userId);
      return right(followers.map((model) => model as Follower).toList());
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures(e.toString()));
    }
  }

  @override
  Future<Either<Failures, void>> unfollowUser(String userIdToUnfollow) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failures('No Internet Connection!'));
      }

      await followerRemoteDataSource.unfollowUser(userIdToUnfollow);
      return right(null);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures(e.toString()));
    }
  }

  @override
  Future<Either<Failures, Follower>> getFollowerDetail(
      String followerId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failures('No Internet Connection!'));
      }

      final FollowerModel followerModel =
          await followerRemoteDataSource.getFollowerDetail(followerId);

      return right(followerModel);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures(e.toString()));
    }
  }
}
