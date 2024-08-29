import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/usecases/usecase.dart';
import 'package:blogapp/features/chat/domain/entities/message.dart';
import 'package:blogapp/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';

class UploadMessage implements UseCase<Message, UploadMessageParams> {
  final ChatRepository chatRepository;

  UploadMessage(this.chatRepository);
  @override
  Future<Either<Failures, Message>> call(UploadMessageParams params) async {
    return await chatRepository.uploadMessage(
        conversationId: params.conversationId,
        posterId: params.posterId,
        recipientId: params.recipientId,
        content: params.content);
  }
}

class UploadMessageParams {
  final String conversationId;
  final String posterId;
  final String recipientId;
  final String content;

  UploadMessageParams(
      {required this.conversationId,
      required this.posterId,
      required this.recipientId,
      required this.content});
}
