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
  final bool isLiked;

  Blog({
    required this.id,
    required this.posterId,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.topics,
    required this.updatedAt,
    this.likes_count = 0,
    this.posterName,
    this.isLiked = false,
  });

  Blog copyWith({
    String? id,
    String? posterId,
    String? title,
    String? content,
    String? imageUrl,
    List<String>? topics,
    DateTime? updatedAt,
    String? posterName,
    int? likes_count,
    bool? isLiked,
  }) {
    return Blog(
      id: id ?? this.id,
      posterId: posterId ?? this.posterId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      topics: topics ?? this.topics,
      updatedAt: updatedAt ?? this.updatedAt,
      likes_count: likes_count ?? this.likes_count,
      posterName: posterName ?? this.posterName,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  String toString() {
    return 'Blog{id: $id, posterId: $posterId, title: $title, content: $content, imageUrl: $imageUrl, topics: ${topics.join(', ')}, updatedAt: $updatedAt, posterName: $posterName, likes_count: $likes_count, isLiked: $isLiked}';
  }
}
