import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CheckEmailVerified implements UseCase<bool, NoParams> {
  final AuthRepository authRepository;

  CheckEmailVerified(this.authRepository);
  @override
  Future<Either<Failures, bool>> call(NoParams params) async {
    return await authRepository.checkEmailVerified();
  }
}
