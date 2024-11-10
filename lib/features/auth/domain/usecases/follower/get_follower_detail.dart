import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/entities/follower.dart';
import 'package:blogapp/features/auth/domain/repository/follower_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetFollowerDetail implements UseCase<Follower, GetFollowerDetailParams> {
  final FollowerRepository followerRepository;

  GetFollowerDetail(this.followerRepository);
  @override
  Future<Either<Failures, Follower>> call(params) async {
    return await followerRepository.getFollowerDetail(params.followerId);
  }
}

class GetFollowerDetailParams {
  final String followerId;

  GetFollowerDetailParams({required this.followerId});
}
