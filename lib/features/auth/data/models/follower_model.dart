import 'package:blogapp/features/auth/domain/entities/follower.dart';

class FollowerModel extends Follower {
  FollowerModel({
    required super.id,
    required super.followerId,
    required super.followedId,
    super.followedAt,
    required super.followerCount,
    super.profileAvatar,
    super.profileName,
  });

  factory FollowerModel.fromJson(Map<String, dynamic> map) {
    return FollowerModel(
        id: map['id'] as String? ??
            '', // Handle null case, ensure id is never null
        followerId: map['follower_id'] as String? ?? '', // Handle null case
        followedId: map['followed_id'] as String? ?? '', // Handle null case
        followedAt: map['followed_at'] == null
            ? null // Set to null if followed_at is not present
            : DateTime.parse(map['followed_at'] as String),
        profileName: map['profile_name'] as String?, // Nullable profile name
        followerCount:
            map['follower_count'] as int? ?? 0, // Default to 0 if null
        profileAvatar: map['profile_avatar_url'] as String? ?? '');
  }

  FollowerModel copyWith(
      {String? id,
      String? followerId,
      String? followedId,
      DateTime? followedAt,
      int? followerCount,
      String? profileName,
      String? profileAvatar}) {
    return FollowerModel(
        id: id ?? this.id,
        followerId: followerId ?? this.followerId,
        followedId: followedId ?? this.followedId,
        followedAt: followedAt ?? this.followedAt,
        followerCount: followerCount ?? this.followerCount,
        profileName: profileName ?? this.profileName,
        profileAvatar: profileAvatar ?? this.profileAvatar);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'followed_id': followedId,
      'followed_at': followedAt?.toIso8601String(),
      'profile_name': profileName,
      'follower_count': followerCount,
    };
  }
}
