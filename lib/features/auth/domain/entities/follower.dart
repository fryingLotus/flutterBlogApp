class Follower {
  final String id;
  final String followerId;
  final String followedId;
  final DateTime? followedAt;
  final String? profileName;
  final String? profileAvatar;
  final int? followerCount;
  final int? blogCount;
  final int? followingCount;
  final bool? isFollowed;
  final bool? isFollowingYou;

  Follower(
      {required this.id,
      required this.followerId,
      required this.followedId,
      this.followedAt,
      this.blogCount,
      this.isFollowingYou,
      this.followerCount,
      this.followingCount,
      this.profileName,
      this.isFollowed,
      this.profileAvatar});
  @override
  String toString() {
    return 'Follower(id: $id, followerId: $followerId, followedId: $followedId, followedAt: $followedAt,profileName: $profileName)';
  }
}
