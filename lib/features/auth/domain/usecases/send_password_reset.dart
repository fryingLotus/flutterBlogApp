import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SendPasswordReset implements UseCase<void, SendPasswordResetParams> {
  final AuthRepository authRepository;

  SendPasswordReset(this.authRepository);
  @override
  Future<Either<Failures, void>> call(SendPasswordResetParams params) async {
    return await authRepository.sendPasswordResetEmail(email: params.email);
  }
}

class SendPasswordResetParams {
  final String email;

  SendPasswordResetParams({required this.email});
}
