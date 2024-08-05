import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blogapp/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failures, String>> signInWithEmailPassword(
      {required String email, required String password}) {
    // TODO: implement signInWithEmailPassword
    throw UnimplementedError();
  }

  @override
  Future<Either<Failures, String>> signUpWithEmailPassword(
      {required String name,
      required String email,
      required String password}) async {
    // TODO: implement signUpWithEmailPassword
    try {
      final userId = await remoteDataSource.signUpWithEmailPassword(
          name: name, email: email, password: password);
      return right(userId);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }
}
