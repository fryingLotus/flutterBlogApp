import 'dart:io';

import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/network/connection_checker.dart';
import 'package:blogapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blogapp/core/entities/user.dart';
import 'package:blogapp/features/auth/data/models/user_model.dart';
import 'package:blogapp/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  const AuthRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failures, User>> currentUser() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final session = remoteDataSource.currentUserSession;
        if (session == null) {
          return left(Failures('User not logged in'));
        }
        return right(UserModel(
            id: session.user.id, email: session.user.email ?? '', name: ''));
      }
      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failures('User not logged in'));
      }
      return right(user);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Future<Either<Failures, User>> signInWithEmailPassword(
      {required String email, required String password}) async {
    return _getUser(() async => await remoteDataSource.loginWithEmailPassword(
        email: email, password: password));
  }

  @override
  Future<Either<Failures, User>> signUpWithEmailPassword(
      {required String name,
      required String email,
      required String password}) async {
    return _getUser(() async => await remoteDataSource.signUpWithEmailPassword(
        name: name, email: email, password: password));
  }

  Future<Either<Failures, User>> _getUser(
    Future<User> Function() fn,
  ) async {
    try {
      final user = await fn();
      return right(user);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Future<Either<Failures, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return right(null);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Future<Either<Failures, User>> updateUser({
    String? email,
    String? name,
    String? password,
  }) async {
    return _getUser(() async {
      return await remoteDataSource.updateUser(
        email: email,
        name: name,
        password: password,
      );
    });
  }

  @override
  Future<Either<Failures, bool>> checkEmailVerified() async {
    try {
      final isVerified = await remoteDataSource.checkEmailVerified();
      return right(isVerified);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures(e.toString()));
    }
  }

  @override
  Future<Either<Failures, void>> resendVerificationEmail({
    required String email,
  }) async {
    try {
      await remoteDataSource.resendVerificationEmail(email: email);
      return right(unit); // Right indicates success with no data to return
    } catch (e) {
      return left(Failures(e.toString()));
    }
  }

  @override
  Future<Either<Failures, User>> updateProfilePicture({
    required File avatarImage,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        throw const ServerException('No internet connection');
      }

      final currentUser = await remoteDataSource.getCurrentUserData();
      if (currentUser == null) {
        return left(Failures('User is not logged in'));
      }

      final avatarUrl = await remoteDataSource.uploadAvatarImage(
        image: avatarImage,
        user: currentUser,
      );

      final updatedUser = await remoteDataSource.updateProfilePicture(
        avatarUrl: avatarUrl,
      );

      return right(updatedUser);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures(e.toString()));
    }
  }

  @override
  Future<Either<Failures, void>> sendPasswordResetEmail(
      {required String email}) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures(e.toString()));
    }
  }

  @override
  Future<Either<Failures, void>> resetPassword(
      {required String email,
      required String code,
      required String newPassword}) async {
    try {
      await remoteDataSource.resetPassword(
          email: email, code: code, newPassword: newPassword);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures(e.toString()));
    }
  }

  @override
  Future<Either<Failures, List<User>>> searchUsers(
      {required String username}) async {
    try {
      final users = await remoteDataSource.searchUsers(username: username);
      return right(users);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures(e.toString()));
    }
  }

  @override
  Future<Either<Failures, User>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      return right(user);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures(e.toString()));
    }
  }

  @override
  Future<Either<Failures, void>> changePassword(
      {required String oldPassword, required String newPassword}) async {
    try {
      await remoteDataSource.changePassword(
          oldPassword: oldPassword, newPassword: newPassword);
      return right(unit);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    } catch (e) {
      return left(Failures(e.toString()));
    }
  }
}
