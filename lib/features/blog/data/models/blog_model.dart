import 'package:blogapp/features/blog/domain/entities/blog.dart';

class BlogModel extends Blog {
  BlogModel(
      {required super.id,
      required super.posterId,
      required super.title,
      required super.content,
      required super.imageUrl,
      required super.topics,
      required super.updatedAt,
      super.posterName,
      super.likes_count,
      bool isLiked = false}) // Default to false
      : super(isLiked: isLiked); // Pass to super class

  factory BlogModel.fromJson(Map<String, dynamic> map) {
    return BlogModel(
      id: map['id'] as String? ?? '', // Default to empty string if null
      posterId: map['poster_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '', // Handle possible null
      topics: List<String>.from(map['topics'] ?? []),
      updatedAt: map['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['updated_at']),
      likes_count: map['likes_count'] as int? ?? 0, // Handle possible null
      posterName: map['poster_name'] as String? ?? "",
    );
  }

  @override
  BlogModel copyWith({
    String? id,
    String? posterId,
    String? title,
    String? content,
    String? imageUrl,
    List<String>? topics,
    DateTime? updatedAt,
    String? posterName,
    int? likes_count,
    bool? isLiked, // Keep isLiked for local state management
  }) {
    return BlogModel(
      id: id ?? this.id,
      posterId: posterId ?? this.posterId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      topics: topics ?? this.topics,
      updatedAt: updatedAt ?? this.updatedAt,
      posterName: posterName ?? this.posterName,
      likes_count: likes_count ?? this.likes_count,
      isLiked: isLiked ?? this.isLiked, // Only managed locally
    );
  }

  // No need to include isLiked in toJson since it is not part of the backend data
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'poster_id': posterId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'topics': topics,
      'updated_at': updatedAt.toIso8601String(),
      'likes_count': likes_count,
    };
  }
}
