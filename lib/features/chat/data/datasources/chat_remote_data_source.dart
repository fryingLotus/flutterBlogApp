import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/features/chat/data/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ChatRemoteDataSource {
  Future<MessageModel> uploadMessage(MessageModel message);
  Stream<List<MessageModel>> subscribeToMessages(String conversationId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient supabaseClient;

  ChatRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<MessageModel> uploadMessage(MessageModel message) async {
    try {
      final response = await supabaseClient
          .from('messages')
          .insert(message.toJson())
          .select()
          .single();

      return MessageModel.fromJson(response, message.posterId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<MessageModel>> subscribeToMessages(String conversationId) {
    final query = supabaseClient
        .from('messages')
        .stream(primaryKey: ['id']).eq('conversation_id', conversationId);

    return query.map((response) {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated');
      }
      return response
          .map((message) => MessageModel.fromJson(message, userId))
          .toList();
    });
  }
}
