import 'package:blogapp/features/chat/domain/entities/message.dart';
import 'package:blogapp/features/chat/domain/usecases/subscribe_to_message.dart';
import 'package:blogapp/features/chat/domain/usecases/upload_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final UploadMessage _uploadMessage;
  final SubscribeToMessage _subscribeToMessages;

  List<Message>? _messages;

  ChatBloc(
      {required UploadMessage uploadMessage,
      required SubscribeToMessage subscribeToMessages})
      : _uploadMessage = uploadMessage,
        _subscribeToMessages = subscribeToMessages,
        super(ChatInitial()) {
    on<ChatUploadMessage>(_onChatUploadMessage);
    on<ChatSubscribeToMessages>(_onChatSubscribeToMessages);
  }

  void _onChatUploadMessage(
      ChatUploadMessage event, Emitter<ChatState> emit) async {
    emit(ChatLoading());

    final result = await _uploadMessage(
      UploadMessageParams(
        conversationId: event.conversationId,
        posterId: event.posterId,
        recipientId: event.recipientId,
        content: event.content,
      ),
    );

    result.fold(
      (failure) => emit(ChatFailure(failure.message)),
      (message) => emit(ChatMessageUploadSuccess()),
    );
  }

  void _onChatSubscribeToMessages(
      ChatSubscribeToMessages event, Emitter<ChatState> emit) {
    emit(ChatLoading());

    final messageStream = _subscribeToMessages(
        SubscribeToMessageParams(conversationId: event.conversationId));

    messageStream.listen((result) {
      result.fold(
        (failure) => addError(failure.message),
        (messages) {
          _messages = messages;
          emit(ChatMessagesLoaded(
            messages: messages,
            hasMore: true, // Assuming there's more to load; adjust as needed
          ));
        },
      );
    });
  }
}

