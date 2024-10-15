import 'dart:io';

import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/entities/user.dart';
import 'package:blogapp/core/secrets/app_secrets.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/auth/domain/usecases/check_email_verified.dart';
import 'package:blogapp/features/auth/domain/usecases/current_user.dart';
import 'package:blogapp/features/auth/domain/usecases/resend_verification_email.dart';
import 'package:blogapp/features/auth/domain/usecases/reset_password.dart';
import 'package:blogapp/features/auth/domain/usecases/search_users.dart';
import 'package:blogapp/features/auth/domain/usecases/send_password_reset.dart';
import 'package:blogapp/features/auth/domain/usecases/update_profile_picture.dart';
import 'package:blogapp/features/auth/domain/usecases/update_user.dart';
import 'package:blogapp/features/auth/domain/usecases/user_google_signin.dart';
import 'package:blogapp/features/auth/domain/usecases/user_login.dart';
import 'package:blogapp/features/auth/domain/usecases/user_logout.dart';
import 'package:blogapp/features/auth/domain/usecases/user_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final UserLogout _userLogout;
  final AppUserCubit _appUserCubit;
  final UpdateUser _updateUser;
  final CheckEmailVerified _checkEmailVerified;
  final ResendVerificationEmail _resendVerificationEmail;
  final UpdateProfilePicture _updateProfilePicture;
  final SendPasswordReset _sendPasswordReset;
  final ResetPassword _resetPassword;
  final SearchUsers _searchUsers;
  final UserGoogleSignin _userGoogleSignin;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
    required UserLogout userLogout,
    required UpdateUser updateUser,
    required CheckEmailVerified checkEmailVerified,
    required ResendVerificationEmail resendVerificationEmail,
    required UpdateProfilePicture updateProfilePicture,
    required SendPasswordReset sendPasswordReset,
    required ResetPassword resetPassword,
    required SearchUsers searchUsers,
    required UserGoogleSignin userGoogleSignin,
  })  : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        _userLogout = userLogout,
        _updateUser = updateUser,
        _checkEmailVerified = checkEmailVerified,
        _resendVerificationEmail = resendVerificationEmail,
        _updateProfilePicture = updateProfilePicture,
        _sendPasswordReset = sendPasswordReset,
        _resetPassword = resetPassword,
        _searchUsers = searchUsers,
        _userGoogleSignin = userGoogleSignin,
        super(AuthInitial()) {
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
    on<AuthLogout>(_onAuthLogout);
    on<AuthUpdate>(_onAuthUpdate);
    on<AuthCheckEmailVerified>(_onAuthCheckEmailVerified);
    on<AuthResendVerificationEmail>(_onAuthResendVerificationEmail);
    on<AuthUpdateProfilePicture>(_onAuthUpdateProfilePicture);
    on<AuthSendPasswordReset>(_onAuthSendPasswordReset);
    on<AuthResetPassword>(_onAuthResetPassword);
    on<AuthSearchUser>(_onAuthSearchUser);
    on<AuthGoogleSignIn>(_onAuthGoogleSignIn);
  }
  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final response = await _userSignUp(UserSignUpParams(
        email: event.email, password: event.password, name: event.name));
    response.fold(
      (failure) {
        emit(AuthFailure(failure.message));
      },
      (user) {
        _emitAuthSuccess(user, emit);
      },
    );
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final response = await _userLogin(
        UserLoginParams(email: event.email, password: event.password));
    response.fold((failure) => emit(AuthFailure(failure.message)),
        (user) => _emitAuthSuccess(user, emit));
  }

  void _isUserLoggedIn(
      AuthIsUserLoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    print("Checking if user is logged in...");
    final res = await _currentUser(NoParams());
    res.fold(
      (failure) {
        print("Failed to get current user: ${failure.message}");
        emit(AuthFailure(failure.message));
      },
      (user) {
        print("User found: ${user.name}");
        _emitAuthSuccess(user, emit);
      },
    );
  }

  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    print("User authenticated: ${user.name}");
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }

  void _onAuthLogout(AuthLogout event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userLogout(NoParams());
    res.fold(
      (failure) {
        emit(AuthFailure(failure.message));
      },
      (_) {
        emit(AuthLoggedOut()); // Emit logged out state
        _appUserCubit.logout(); // Call logout method
      },
    );
  }

  void _onAuthUpdate(AuthUpdate event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    print("AuthUpdate event triggered:");
    print("Name: ${event.name}");
    print("Email: ${event.email}");
    print("Password: ${event.password}");

    final response = await _updateUser(UpdateUserParams(
      email: event.email,
      password: event.password,
      name: event.name,
    ));

    response.fold(
      (failure) {
        print("Update failed: ${failure.message}");
        emit(AuthFailure(failure.message));
      },
      (user) {
        print("Update successful: User ${user.name} ${user.email} updated");
        _emitAuthSuccess(user, emit);
      },
    );
  }

  void _onAuthCheckEmailVerified(
      AuthCheckEmailVerified event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    // First, get the current user session
    final currentUserResponse = await _currentUser(NoParams());
    currentUserResponse.fold(
      (failure) {
        emit(AuthFailure(failure.message));
      },
      (user) async {
        // Now check if the email is verified
        final response = await _checkEmailVerified(NoParams());
        response.fold(
          (failure) {
            emit(AuthFailure(failure.message));
          },
          (isVerified) {
            if (isVerified) {
              // Email is verified, navigate to blog page
              emit(AuthEmailVerifiedSuccess());
            } else {
              // Email not verified yet, update UI accordingly
              emit(AuthEmailNotVerified());
            }
          },
        );
      },
    );
  }

  void _onAuthResendVerificationEmail(
      AuthResendVerificationEmail event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final response = await _resendVerificationEmail(
      ResendVerificationEmailParams(email: event.email),
    );
    response.fold(
      (failure) {
        print("resend${failure.message}");
        emit(AuthFailure(failure.message));
      },
      (_) {
        emit(const AuthSuccessMessage(
            "Verification email resent")); // Custom state for successful resend
      },
    );
  }

  void _onAuthUpdateProfilePicture(
      AuthUpdateProfilePicture event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final response = await _updateProfilePicture(
        UpdateProfilePictureParams(avatarImage: event.avatarImage));
    response.fold(
      (failure) {
        emit(AuthFailure(failure.message));
      },
      (user) {
        _emitAuthSuccess(user, emit);
      },
    );
  }

  void _onAuthSendPasswordReset(
      AuthSendPasswordReset event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final response =
        await _sendPasswordReset(SendPasswordResetParams(email: event.email));

    response.fold(
      (failure) {
        emit(AuthFailure(failure.message));
      },
      (_) {
        emit(const AuthSuccessMessage("Password Reset Sent to email"));
      },
    );
  }

  void _onAuthResetPassword(
      AuthResetPassword event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final response = await _resetPassword(ResetPasswordParams(
        email: event.email, code: event.code, newPassword: event.password));
    response.fold(
      (failure) {
        emit(AuthFailure(failure.message));
      },
      (_) {
        emit(const AuthSuccessMessage("Succesfully updated password"));
      },
    );
  }

  void _onAuthSearchUser(AuthSearchUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final response =
        await _searchUsers(SearchUsersParams(username: event.username));
    response.fold(
      (failure) {
        emit(AuthFailure(failure.message));
      },
      (r) {
        emit(AuthSearchSuccess(r));
      },
    );
  }

  Future<void> signOutGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: AppSecrets.iosClientId,
      serverClientId: AppSecrets.webClientId,
    );

    await googleSignIn.signOut();
  }

  void _onAuthGoogleSignIn(
      AuthGoogleSignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await signOutGoogle();
    final response = await _userGoogleSignin(NoParams());

    response.fold(
      (failure) {
        emit(AuthFailure(failure.message));
      },
      (user) {
        _emitAuthSuccess(user, emit);
      },
    );
  }
}
