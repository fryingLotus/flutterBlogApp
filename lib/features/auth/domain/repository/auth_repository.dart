import 'dart:io';

import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failures, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<Either<Failures, User>> signInWithEmailPassword({
    required String email,
    required String password,
  });
  Future<Either<Failures, User>> currentUser();
  Future<Either<Failures, void>> logout();
  Future<Either<Failures, User>> updateUser(
      {String? email, String? name, String? password});

  Future<Either<Failures, void>> resendVerificationEmail(
      {required String email});
  Future<Either<Failures, bool>> checkEmailVerified();
  Future<Either<Failures, User>> updateProfilePicture({
    required File avatarImage,
  });
}
