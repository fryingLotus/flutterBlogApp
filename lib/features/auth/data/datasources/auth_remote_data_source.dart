import 'dart:io';

import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/core/secrets/app_secrets.dart';
import 'package:blogapp/features/auth/data/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  Future<UserModel> updateUser({
    String? name,
    String? email,
    String? password,
  });

  Future<void> resendVerificationEmail({
    required String email,
  });

  Future<bool> checkEmailVerified();

  // New methods
  Future<UserModel> updateProfilePicture({
    required String avatarUrl,
  });

  Future<String> uploadAvatarImage({
    required File image,
    required UserModel user,
  });
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> resetPassword(
      {required String email,
      required String code,
      required String newPassword});
  Future<List<UserModel>> searchUsers({required String username});
  Future<UserModel> signInWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

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
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
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
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient
            .from('profiles')
            .select('id,name,avatar_url')
            .eq('id', currentUserSession!.user.id)
            .single();

        return UserModel.fromJson(userData)
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
    } catch (e) {
      throw ServerException(e.toString());
    }
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

      final updatedName = name ?? currentUserData.name;
      final updatedEmail = email ?? currentUserData.email;

      if (name != null) {
        await supabaseClient
            .from('profiles')
            .update({'name': updatedName}).eq('id', currentUserData.id);
      }

      if (email != null || password != null) {
        final attributes = UserAttributes(
          email: email ?? currentUserData.email,
          password: password,
        );

        final response = await supabaseClient.auth.updateUser(attributes);
        if (response.user == null) {
          throw const ServerException('User is null after update!');
        }
      }

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
  Future<void> resendVerificationEmail({
    required String email,
  }) async {
    try {
      await supabaseClient.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } on AuthException catch (e) {
      print("AuthException: ${e.message}");
      throw ServerException(e.message);
    } catch (e) {
      print("General exception: $e");
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    try {
      final user = supabaseClient.auth.currentUser;

      return user?.emailConfirmedAt != null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadAvatarImage({
    required File image,
    required UserModel user,
  }) async {
    try {
      final uniqueId = '${user.id}_${DateTime.now().millisecondsSinceEpoch}';

      await supabaseClient.storage.from('avatars').upload(uniqueId, image);

      return supabaseClient.storage.from('avatars').getPublicUrl(uniqueId);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> updateProfilePicture({
    required String avatarUrl,
  }) async {
    try {
      final currentUserData = await getCurrentUserData();
      if (currentUserData == null) {
        throw const ServerException('No user data available!');
      }

      await supabaseClient
          .from('profiles')
          .update({'avatar_url': avatarUrl}).eq('id', currentUserData.id);

      return currentUserData.copyWith(avatarUrl: avatarUrl);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      // Verify OTP
      await supabaseClient.auth.verifyOTP(
        type: OtpType.recovery,
        email: email,
        token: code,
      );

      // Update password
      final updateResponse = await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      // Check if the update was successful
      if (updateResponse.user == null) {
        throw const ServerException('Failed to update password');
      }
    } on AuthException catch (e) {
      switch (e.message) {
        case 'Invalid otp':
          throw const ServerException('Invalid verification code');
        case 'User not found':
          throw const ServerException('User not found');
        default:
          throw ServerException('Authentication error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> searchUsers({required String username}) async {
    try {
      final users = await supabaseClient
          .from('profiles')
          .select()
          .like('name', '%$username%');
      return users
          .map((user) => UserModel.fromJson(user)
              .copyWith(name: user['name'], avatarUrl: user['avatar_url']))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    const webClientId = AppSecrets.webClientId;
    const iosClientId = AppSecrets.iosClientId;

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw const ServerException('Google sign-in aborted.');
    }

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw const ServerException('No Access Token found.');
    }
    if (idToken == null) {
      throw const ServerException('No ID Token found.');
    }

    final response = await supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    final user = response.user;
    if (user == null) {
      throw const ServerException('User is null after Google sign-in!');
    }

    return UserModel.fromJson(user.toJson());
  }
}
