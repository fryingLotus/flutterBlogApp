import 'package:blogapp/features/auth/domain/entities/user.dart';
import 'package:blogapp/features/auth/domain/usecases/user_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;

  AuthBloc({required UserSignUp userSignUp})
      : _userSignUp = userSignUp,
        super(AuthInitial()) {
    on<AuthSignUp>((event, emit) async {
      try {
        emit(AuthLoading());
        final response = await _userSignUp(UserSignUpParams(
            email: event.email, password: event.password, name: event.name));
        response.fold(
          (failure) {
            print('Signup failed: ${failure.message}');
            emit(AuthFailure(failure.message));
          },
          (user) {
            print('Signup successful: $user');
            emit(AuthSuccess(user));
          },
        );
      } catch (e) {
        print('Signup error: $e');
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
