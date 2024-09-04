class Follower {
  final String id;
  final String followerId;
  final String followedId;
  final DateTime? followedAt;
  final String? profileName;
  final String? profileAvatar;
  final int? followerCount;

  Follower(
      {required this.id,
      required this.followerId,
      required this.followedId,
      this.followedAt,
      this.followerCount,
      this.profileName,
      this.profileAvatar});
  @override
  String toString() {
    return 'Follower(id: $id, followerId: $followerId, followedId: $followedId, followedAt: $followedAt,profileName: $profileName)';
  }
}
