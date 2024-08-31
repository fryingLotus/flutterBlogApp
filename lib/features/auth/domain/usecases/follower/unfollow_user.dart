import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/repository/follower_repository.dart';
import 'package:fpdart/fpdart.dart';

class UnfollowUser implements UseCase<void, UnfollowUserParams> {
  final FollowerRepository followerRepository;

  UnfollowUser(this.followerRepository);

  @override
  Future<Either<Failures, void>> call(UnfollowUserParams params) async {
    return await followerRepository.unfollowUser(params.userIdToUnfollow);
  }
}

class UnfollowUserParams {
  final String userIdToUnfollow;

  UnfollowUserParams({required this.userIdToUnfollow});
}
