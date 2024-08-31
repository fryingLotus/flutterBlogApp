import 'package:blogapp/features/auth/domain/entities/follower.dart';

class FollowerModel extends Follower {
  FollowerModel(
      {required super.id,
      required super.followerId,
      required super.followedId,
      required super.followedAt});
  factory FollowerModel.fromJson(Map<String, dynamic> map) {
    return FollowerModel(
      id: map['id'] as String,
      followerId: map['follower_id'] as String,
      followedId: map['followed_id'] as String,
      followedAt: map['followed_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['followed_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'followed_id': followedId,
      'followed_at': followedAt.toIso8601String(),
    };
  }
}
