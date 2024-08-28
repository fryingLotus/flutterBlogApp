import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/features/chat/domain/entities/message.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ChatRepository {
  Future<Either<Failures, Message>> uploadMessage({
    required String conversationId,
    required String posterId,
    required String recipientId,
    required String content,
  });

  Stream<Either<Failures, List<Message>>> subscribeToMessages(
      String conversationId);
}
