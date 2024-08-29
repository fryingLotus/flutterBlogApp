import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/features/chat/domain/entities/message.dart';
import 'package:blogapp/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';

class SubscribeToMessage {
  final ChatRepository chatRepository;

  SubscribeToMessage(this.chatRepository);

  Stream<Either<Failures, List<Message>>> call(
      SubscribeToMessageParams params) {
    return chatRepository.subscribeToMessages(params.conversationId);
  }
}

class SubscribeToMessageParams {
  final String conversationId;

  SubscribeToMessageParams({required this.conversationId});
}

