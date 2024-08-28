import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/core/error/failures.dart';
import 'package:blogapp/core/network/connection_checker.dart';
import 'package:blogapp/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:blogapp/features/chat/data/models/message_model.dart';
import 'package:blogapp/features/chat/domain/entities/message.dart';
import 'package:blogapp/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource chatRemoteDataSource;
  final ConnectionChecker connectionChecker;

  ChatRepositoryImpl(this.chatRemoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failures, Message>> uploadMessage(
      {required String conversationId,
      required String posterId,
      required String recipientId,
      required String content}) async {
    try {
      MessageModel messageModel = MessageModel(
        id: const Uuid().v1(),
        conversationId: conversationId,
        posterId: posterId,
        recipientId: recipientId,
        content: content,
        createdAt: DateTime.now(),
      );
      final uploadedMessage =
          await chatRemoteDataSource.uploadMessage(messageModel);
      return right(uploadedMessage);
    } on ServerException catch (e) {
      return left(Failures(e.message));
    }
  }

  @override
  Stream<Either<Failures, List<Message>>> subscribeToMessages(
      String conversationId) {
    // TODO: implement subscribeToMessages
    throw UnimplementedError();
  }
}
