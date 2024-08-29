part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

// Event for uploading a message
class ChatUploadMessage extends ChatEvent {
  final String conversationId;
  final String posterId;
  final String recipientId;
  final String content;

  ChatUploadMessage({
    required this.conversationId,
    required this.posterId,
    required this.recipientId,
    required this.content,
  });
}

// Event for subscribing to messages in a conversation
class ChatSubscribeToMessages extends ChatEvent {
  final String conversationId;

  ChatSubscribeToMessages({required this.conversationId});
}

