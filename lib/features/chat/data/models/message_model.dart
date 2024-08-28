import 'package:blogapp/features/chat/domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required super.id,
    required super.conversationId,
    required super.posterId,
    required super.recipientId,
    required super.content,
    required super.createdAt,
    super.posterName,
  });

  factory MessageModel.fromJson(Map<String, dynamic> map, String myUserId) {
    return MessageModel(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      posterId: map['poster_id'] as String,
      recipientId: map['recipient_id'] as String,
      content: map['content'] as String,
      createdAt: map['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['created_at']),
      posterName: map['poster_name'] as String?,
    );
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? posterId,
    String? recipientId,
    String? content,
    DateTime? createdAt,
    String? posterName,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      posterId: posterId ?? this.posterId,
      recipientId: recipientId ?? this.recipientId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      posterName: posterName ?? this.posterName,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'conversation_id': conversationId,
      'poster_id': posterId,
      'recipient_id': recipientId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'poster_name': posterName,
    };
  }
}

