part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignUp extends AuthEvent {
  final String email;
  final String password;
  final String name;

  AuthSignUp({required this.email, required this.password, required this.name});
}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin({required this.email, required this.password});
}

class AuthUpdate extends AuthEvent {
  final String? name;
  final String? email;
  final String? password;

  AuthUpdate({this.name, this.email, this.password});
}

final class AuthIsUserLoggedIn extends AuthEvent {}

final class AuthLogout extends AuthEvent {}

final class AuthLoggedOut extends AuthState {}

class AuthResendVerificationEmail extends AuthEvent {
  final String email;

  AuthResendVerificationEmail({required this.email});
}

class AuthCheckEmailVerified extends AuthEvent {}

class AuthUpdateProfilePicture extends AuthEvent {
  final File avatarImage;

  AuthUpdateProfilePicture({required this.avatarImage});
}
