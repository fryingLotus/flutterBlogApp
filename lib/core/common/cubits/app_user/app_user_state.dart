part of 'app_user_cubit.dart';

@immutable
sealed class AppUserState {}

final class AppUserInitial extends AppUserState {}

final class AppUserLoggedIn extends AppUserState {
  final User user;
  AppUserLoggedIn(this.user);
}

final class AppUserLoading extends AppUserState {}

final class AppUserUpdateError extends AppUserState {
  final String message;
  AppUserUpdateError(this.message);
}
