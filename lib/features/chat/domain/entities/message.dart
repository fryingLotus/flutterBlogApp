class Message {
  final String id;
  final String conversationId;
  final String posterId;
  final String recipientId;
  final String content;
  final DateTime createdAt;
  final String? posterName;

  Message({
    required this.id,
    required this.conversationId,
    required this.posterId,
    required this.recipientId,
    required this.content,
    required this.createdAt,
    this.posterName,
  });
}

