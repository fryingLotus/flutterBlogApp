import 'package:blogapp/core/entities/user.dart';
import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SearchUsers implements UseCase<List<User>, SearchUsersParams> {
  final AuthRepository authRepository;

  SearchUsers(this.authRepository);
  @override
  Future<Either<Failures, List<User>>> call(SearchUsersParams params) async {
    return await authRepository.searchUsers(username: params.username);
  }
}

class SearchUsersParams {
  final String username;

  SearchUsersParams({required this.username});
}
