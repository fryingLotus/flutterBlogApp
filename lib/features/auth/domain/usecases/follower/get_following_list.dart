import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/entities/follower.dart';
import 'package:blogapp/features/auth/domain/repository/follower_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetFollowingList
    implements UseCase<List<Follower>, GetFollowingListParams> {
  final FollowerRepository followerRepository;

  GetFollowingList(this.followerRepository);

  @override
  Future<Either<Failures, List<Follower>>> call(
      GetFollowingListParams params) async {
    return await followerRepository.getFollowingList(params.userId);
  }
}

class GetFollowingListParams {
  final String userId;

  GetFollowingListParams({required this.userId});
}

