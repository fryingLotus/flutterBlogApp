import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/entities/follower.dart';
import 'package:blogapp/features/auth/domain/repository/follower_repository.dart';
import 'package:fpdart/fpdart.dart';

class FollowUser implements UseCase<Follower, FollowUserParams> {
  final FollowerRepository followerRepository;

  FollowUser(this.followerRepository);
  @override
  Future<Either<Failures, Follower>> call(FollowUserParams params) async {
    return await followerRepository.followUser(
        followedId: params.followedId, followerId: params.followerId);
  }
}

class FollowUserParams {
  final String followedId;
  final String followerId;

  FollowUserParams({required this.followedId, required this.followerId});
}
