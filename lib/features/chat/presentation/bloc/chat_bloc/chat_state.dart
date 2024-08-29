part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatFailure extends ChatState {
  final String error;
  ChatFailure(this.error);
}

class ChatMessageUploadSuccess extends ChatState {}

final class ChatMessagesLoaded extends ChatState {
  final List<Message> messages;
  final bool hasMore;

  ChatMessagesLoaded({
    required this.messages,
    required this.hasMore,
  });
}
