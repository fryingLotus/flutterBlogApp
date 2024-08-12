import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/core/entities/user.dart';
import 'package:blogapp/features/auth/domain/usecases/current_user.dart';
import 'package:blogapp/features/auth/domain/usecases/user_login.dart';
import 'package:blogapp/features/auth/domain/usecases/user_logout.dart';
import 'package:blogapp/features/auth/domain/usecases/user_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final UserLogout _userLogout;
  final AppUserCubit _appUserCubit;

  AuthBloc(
      {required UserSignUp userSignUp,
      required UserLogin userLogin,
      required CurrentUser currentUser,
      required AppUserCubit appUserCubit,
      required UserLogout userLogout})
      : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        _userLogout = userLogout,
        super(AuthInitial()) {
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
    on<AuthLogout>(_onAuthLogout);
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
}
