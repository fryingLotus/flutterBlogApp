import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentUserSession;
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<UserModel?> getCurrentUserData();
  Future<void> logout();
  Future<UserModel> updateUser({String? name, String? email, String? password});
  Future<void> resendVerificationEmail({required String email});
  Future<bool> checkEmailVerified();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;
  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );

      final user = response.user;

      if (user == null) {
        throw const ServerException('User is null!');
      }

      if (user.emailConfirmedAt == null) {
        throw const ServerException('Please verify your email first.');
      }

      return UserModel.fromJson(user.toJson());
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final response = await supabaseClient.auth
          .signUp(password: password, email: email, data: {
        'name': name,
      });
      if (response.user == null) {
        throw const ServerException('User is null!');
      }
      return UserModel.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient
            .from('profiles')
            .select('id,name')
            .eq('id', currentUserSession!.user.id);
        return UserModel.fromJson(userData.first)
            .copyWith(email: currentUserSession!.user.email);
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
    return null;
  }

  @override
  Future<void> logout() async {
    try {
      if (currentUserSession != null) {
        await supabaseClient.auth.signOut();
      }
    } on AuthException catch (e) {
      throw ServerException(e.message);
    }
    (e) {
      throw ServerException(e.toString());
    };
  }

  @override
  Future<UserModel> updateUser({
    String? name,
    String? email,
    String? password,
  }) async {
    try {
      final currentUserData = await getCurrentUserData();
      if (currentUserData == null) {
        throw const ServerException('No user data available!');
      }

      // Prepare the updated fields
      String updatedName = name ?? currentUserData.name;
      String updatedEmail = email ?? currentUserData.email;

      // Update the user's profile in the 'profiles' table if the name is provided
      if (name != null) {
        await supabaseClient
            .from('profiles')
            .update({'name': updatedName}).eq('id', currentUserData.id);
      }

      // Update email and/or password using the Supabase Auth API if provided
      UserAttributes? attributes;
      if (email != null || password != null) {
        attributes = UserAttributes(
          email: email != null ? updatedEmail : null,
          password: password != null && password.isNotEmpty ? password : null,
        );
      }

      if (attributes != null) {
        final response = await supabaseClient.auth.updateUser(attributes);
        if (response.user == null) {
          throw const ServerException('User is null after update!');
        }
      }

      // Return updated UserModel
      return currentUserData.copyWith(
        name: updatedName,
        email: updatedEmail,
      );
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> resendVerificationEmail({required String email}) async {
    try {
      final ResendResponse response = await supabaseClient.auth.resend(
          type: OtpType.email, // Indicates that this is for email verification
          email: email,
          emailRedirectTo: 'io.supabase.flutterquickstart://login-callback/');
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    final user = supabaseClient.auth.currentUser;
    if (user != null) {
      // Check if emailConfirmedAt is not null
      return user.emailConfirmedAt != null;
    }
    return false;
  }
}
