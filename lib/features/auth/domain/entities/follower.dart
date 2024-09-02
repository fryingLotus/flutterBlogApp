class Follower {
  final String id;
  final String followerId;
  final String followedId;
  final DateTime followedAt;
  final String? profileName;
  final int followerCount;

  Follower(
      {required this.id,
      required this.followerId,
      required this.followedId,
      required this.followedAt,
      required this.followerCount,
      this.profileName});
}
