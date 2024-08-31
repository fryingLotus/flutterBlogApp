// data/datasources/follower_remote_data_source.dart
import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/features/auth/data/models/follower_model.dart';
import 'package:blogapp/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class FollowerRemoteDataSource {
  Future<FollowerModel> followUser(FollowerModel follower);
  Future<void> unfollowUser(String userIdToUnfollow);
  Future<List<UserModel>> getFollowers(String userId);
  Future<UserModel> getFollowerDetail(String followerId);
}

class FollowerRemoteDataSourceImpl implements FollowerRemoteDataSource {
  final SupabaseClient supabaseClient;

  FollowerRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<FollowerModel> followUser(FollowerModel follower) async {
    try {
      final followData = await supabaseClient
          .from('followers')
          .insert(follower.toJson())
          .select();
      return FollowerModel.fromJson(followData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> unfollowUser(String userIdToUnfollow) async {
    try {
      final userId = supabaseClient.auth.currentSession!.user.id;
      await supabaseClient
          .from('followers')
          .delete()
          .eq('follower_id', userId)
          .eq('followed_id', userIdToUnfollow);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<UserModel>> getFollowers(String userId) async {
    try {
      final response = await supabaseClient
          .from('followers')
          .select('profiles(id, name, avatar_url)')
          .eq('followed_id', userId);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> getFollowerDetail(String followerId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select('id, name, avatar_url')
          .eq('id', followerId)
          .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
