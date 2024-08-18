// ignore_for_file: non_constant_identifier_names

class Blog {
  final String id;
  final String posterId;
  final String title;
  final String content;
  final String imageUrl;
  final List<String> topics;
  final DateTime updatedAt;
  final String? posterName;
  final int? likes_count;

  Blog(
      {required this.id,
      required this.posterId,
      required this.title,
      required this.content,
      required this.imageUrl,
      required this.topics,
      required this.updatedAt,
      this.likes_count,
      this.posterName});
}
