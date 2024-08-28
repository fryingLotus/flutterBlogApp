class Message {
  final String id;
  final String conversationId;
  final String posterId;
  final String recipientId;
  final String content;
  final DateTime createdAt;
  final bool isMine;
  final String? posterName;

  Message({
    required this.id,
    required this.conversationId,
    required this.posterId,
    required this.recipientId,
    required this.content,
    required this.createdAt,
    required this.isMine,
    this.posterName,
  });
}

