import 'package:blogapp/features/auth/domain/entities/follower.dart';

class FollowerModel extends Follower {
  FollowerModel({
    required super.id,
    required super.followerId,
    required super.followedId,
    required super.followedAt,
    required super.followerCount,
    super.profileName,
  });

  factory FollowerModel.fromJson(Map<String, dynamic> map) {
    return FollowerModel(
      id: map['id'] as String,
      followerId: map['follower_id'] as String,
      followedId: map['followed_id'] as String,
      followedAt: map['followed_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['followed_at']),
      profileName: map['profile_name'] as String?,
      followerCount: map['follower_count'] as int? ?? 0,
    );
  }
  FollowerModel copyWith({
    String? id,
    String? followerId,
    String? followedId,
    DateTime? followedAt,
    int? followerCount,
    String? profileName,
  }) {
    return FollowerModel(
      id: id ?? this.id,
      followerId: followerId ?? this.followerId,
      followedId: followedId ?? this.followedId,
      followedAt: followedAt ?? this.followedAt,
      followerCount: followerCount ?? this.followerCount,
      profileName: profileName ?? this.profileName,
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

