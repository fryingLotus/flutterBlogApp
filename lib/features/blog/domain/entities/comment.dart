// ignore_for_file: non_constant_identifier_names

class Comment {
  final String id;
  final String posterId;
  final String blogId;
  final String content;
  final String? posterAvatar;
  final DateTime updatedAt;
  final DateTime createdAt;
  final String? posterName;
  final int? likes_count;
  final bool isLiked;
  Comment(
      {required this.id,
      required this.posterId,
      required this.blogId,
      required this.content,
      required this.updatedAt,
      required this.createdAt,
      this.likes_count = 0,
      this.isLiked = false,
      this.posterAvatar,
      this.posterName});
  Comment copyWith({
    String? id,
    String? posterId,
    String? blogId,
    String? content,
    String? posterAvatar,
    DateTime? updatedAt,
    DateTime? createdAt,
    String? posterName,
    int? likes_count,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      posterId: posterId ?? this.posterId,
      blogId: blogId ?? this.blogId,
      content: content ?? this.content,
      posterAvatar: posterAvatar ?? this.posterAvatar,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      posterName: posterName ?? this.posterName,
      likes_count: likes_count ?? this.likes_count,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
