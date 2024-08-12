import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserLogout implements UseCase<void, NoParams> {
  final AuthRepository authRepository;

  UserLogout(this.authRepository);

  @override
  Future<Either<Failures, void>> call(NoParams params) async {
    return await authRepository.logout();
  }
}
