class Follower {
  final String id;
  final String followerId;
  final String followedId;
  final DateTime followedAt;

  Follower(
      {required this.id,
      required this.followerId,
      required this.followedId,
      required this.followedAt});
}
