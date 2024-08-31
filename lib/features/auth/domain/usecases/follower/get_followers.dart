import 'package:blogapp/core/entities/user.dart';
import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/repository/follower_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetFollowers implements UseCase<List<User>, GetFollowersParams> {
  final FollowerRepository followerRepository;

  GetFollowers(this.followerRepository);

  @override
  Future<Either<Failures, List<User>>> call(GetFollowersParams params) async {
    return await followerRepository.getFollowers(params.userId);
  }
}

class GetFollowersParams {
  final String userId;

  GetFollowersParams({required this.userId});
}
