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
  Future<UserModel> updateUser({ String? name, String? email,String? password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;
  @override
  Future<UserModel> loginWithEmailPassword(
      {required String email, required String password}) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
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
    
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;

   
    if (data.isEmpty) {
      throw const ServerException('No fields provided to update!');
    }

   
    final attributes = UserAttributes(
      data: name != null ? {'name': name} : null,
      email: email,
      password: password,
    );

   
    final response = await supabaseClient.auth.updateUser(attributes);

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
}
