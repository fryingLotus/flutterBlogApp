import 'package:blogapp/core/entities/user.dart';
import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateUser implements UseCase<User, UpdateUserParams> {
  final AuthRepository authRepository;

  UpdateUser(this.authRepository);
  @override
  Future<Either<Failures, User>> call(UpdateUserParams params) async {
    return await authRepository.updateUser(
        name: params.name, email: params.email, password: params.password);
  }
}

class UpdateUserParams {
  final String? name;
  final String? email;
  final String? password;

  UpdateUserParams(
      {required this.name, required this.email, required this.password});
}
