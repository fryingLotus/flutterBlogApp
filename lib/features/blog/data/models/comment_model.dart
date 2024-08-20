// ignore_for_file: non_constant_identifier_names

import 'package:blogapp/features/blog/domain/entities/comment.dart';

class CommentModel extends Comment {
  CommentModel(
      {required super.id,
      required super.posterId,
      required super.blogId,
      required super.content,
      required super.createdAt,
      required super.updatedAt,
      super.posterAvatar,
      super.posterName,
      super.likes_count,
      bool isLiked = false}) // Default to false
      : super(isLiked: isLiked); // Pass to super class

  factory CommentModel.fromJson(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      posterId: map['poster_id'] as String,
      blogId: map['blog_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['updated_at']),
      likes_count: map['likes_count'] != null ? map['likes_count'] as int : 0,
    );
  }
  factory CommentModel.fromComment(Comment comment) {
    return CommentModel(
      id: comment.id,
      posterId: comment.posterId,
      blogId: comment.blogId,
      content: comment.content,
      posterAvatar: comment.posterAvatar,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
      posterName: comment.posterName,
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
    int? likes_count,
    bool? isLiked, // Keep isLiked for local state management
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
      likes_count: likes_count ?? this.likes_count,
      isLiked: isLiked ?? this.isLiked, // Only managed locally
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'poster_id': posterId,
      'blog_id': blogId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'likes_count': likes_count,
    };
  }
}
