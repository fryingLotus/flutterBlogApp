class Comment {
  final String id;
  final String posterId;
  final String blogId;
  final String content;
  final String? posterAvatar;
  final DateTime updatedAt;
  final DateTime createdAt;
  final String? posterName;

  Comment(
      {required this.id,
      required this.posterId,
      required this.blogId,
      required this.content,
      required this.updatedAt,
      required this.createdAt,
      this.posterAvatar,
      this.posterName});
}
