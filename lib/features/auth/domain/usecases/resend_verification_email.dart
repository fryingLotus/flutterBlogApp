import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ResendVerificationEmail
    implements UseCase<void, ResendVerificationEmailParams> {
  final AuthRepository authRepository;

  ResendVerificationEmail(this.authRepository);
  @override
  Future<Either<Failures, void>> call(
      ResendVerificationEmailParams params) async {
    return await authRepository.resendVerificationEmail(email: params.email);
  }
}

class ResendVerificationEmailParams {
  final String email;

  ResendVerificationEmailParams({required this.email});
}
