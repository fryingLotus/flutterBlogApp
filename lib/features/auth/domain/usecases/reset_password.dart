import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ResetPassword implements UseCase<void, ResetPasswordParams> {
  final AuthRepository authRepository;

  ResetPassword(this.authRepository);
  @override
  Future<Either<Failures, void>> call(ResetPasswordParams params) async {
    return await authRepository.resetPassword(
        email: params.email,
        code: params.code,
        newPassword: params.newPassword);
  }
}

class ResetPasswordParams {
  final String email;
  final String code;
  final String newPassword;

  ResetPasswordParams(
      {required this.email, required this.code, required this.newPassword});
}
