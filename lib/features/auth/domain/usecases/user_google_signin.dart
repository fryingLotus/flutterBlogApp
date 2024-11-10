import 'package:blogapp/core/entities/user.dart';
import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserGoogleSignin implements UseCase<User, NoParams> {
  final AuthRepository authRepository;

  UserGoogleSignin(this.authRepository);
  @override
  Future<Either<Failures, User>> call(NoParams params) async {
    return await authRepository.signInWithGoogle();
  }
}
