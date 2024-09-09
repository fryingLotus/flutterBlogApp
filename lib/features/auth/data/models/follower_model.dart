import 'package:blogapp/features/auth/domain/entities/follower.dart';

class FollowerModel extends Follower {
  FollowerModel(
      {required super.id,
      required super.followerId,
      required super.followedId,
      super.followedAt,
      super.isFollowed,
      super.followerCount,
      super.profileAvatar,
      super.profileName,
      super.followingCount,
      super.blogCount});

  factory FollowerModel.fromJson(Map<String, dynamic> map) {
    print('received json $map');
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
        blogCount: map['blog_count'] as int? ?? 0, // Default to 0 if null
        followingCount:
            map['following_count'] as int? ?? 0, // Default to 0 if null
        isFollowed: map['is_followed'] as bool? ?? false,
        profileAvatar: map['profile_avatar_url'] as String? ?? '');
  }

  FollowerModel copyWith(
      {String? id,
      String? followerId,
      String? followedId,
      DateTime? followedAt,
      int? followerCount,
      int? followingCount,
      String? profileName,
      bool? isFollowed,
      int? blogCount,
      String? profileAvatar}) {
    return FollowerModel(
        id: id ?? this.id,
        followerId: followerId ?? this.followerId,
        followedId: followedId ?? this.followedId,
        followedAt: followedAt ?? this.followedAt,
        followerCount: followerCount ?? this.followerCount,
        blogCount: blogCount ?? this.blogCount,
        followingCount: followingCount ?? this.followingCount,
        profileName: profileName ?? this.profileName,
        isFollowed: isFollowed ?? this.isFollowed,
        profileAvatar: profileAvatar ?? this.profileAvatar);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'followed_id': followedId,
      'followed_at': followedAt?.toIso8601String(),
    };
  }
}
