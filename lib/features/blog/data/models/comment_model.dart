import 'package:blogapp/features/blog/domain/entities/comment.dart';

class CommentModel extends Comment {
  CommentModel({
    required super.id,
    required super.posterId,
    required super.blogId,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
    super.posterAvatar,
    super.posterName,
  });

  factory CommentModel.fromJson(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      posterId: map['poster_id'] as String,
      blogId: map['blog_id'] as String,
      content: map['content'] as String,
      posterAvatar: map['poster_avatar'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['updated_at']),
      posterName: map['poster_name'] as String?,
    );
  }

  CommentModel copyWith({
    String? id,
    String? posterId,
    String? blogId,
    String? content,
    String? posterAvatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? posterName,
  }) {
    return CommentModel(
      id: id ?? this.id,
      posterId: posterId ?? this.posterId,
      blogId: blogId ?? this.blogId,
      content: content ?? this.content,
      posterAvatar: posterAvatar ?? this.posterAvatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      posterName: posterName ?? this.posterName,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'poster_id': posterId,
      'blog_id': blogId,
      'content': content,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'poster_name': posterName,
    };
  }
}
