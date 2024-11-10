import 'dart:io';

import 'package:blogapp/core/entities/user.dart';
import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateProfilePicture
    implements UseCase<User, UpdateProfilePictureParams> {
  final AuthRepository authRepository;

  UpdateProfilePicture(this.authRepository);

  @override
  Future<Either<Failures, User>> call(UpdateProfilePictureParams params) async {
    return await authRepository.updateProfilePicture(
        avatarImage: params.avatarImage);
  }
}

class UpdateProfilePictureParams {
  final File avatarImage;

  UpdateProfilePictureParams({required this.avatarImage});
}

