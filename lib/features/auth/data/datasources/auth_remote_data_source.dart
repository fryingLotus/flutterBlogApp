import 'dart:io';

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
        type: OtpType.email,
        email: email,
        emailRedirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    try {
      final response = await supabaseClient.auth.refreshSession();
      final user = response.user;

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
}
