import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/features/blog/data/models/comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class CommentRemoteDataSource {
  Future<CommentModel> uploadComment(CommentModel comment);
  Future<List<CommentModel>> getCommentsForBlog(String blogId);
  Future<void> deleteComment(String commentId);
  Future<CommentModel> updateComment(CommentModel comment);
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final SupabaseClient supabaseClient;

  CommentRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<CommentModel> uploadComment(CommentModel comment) async {
    try {
      final commentData = await supabaseClient
          .from('comments')
          .insert(comment.toJson())
          .select();
      return CommentModel.fromJson(commentData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<CommentModel>> getCommentsForBlog(String blogId) async {
    try {
      final comments = await supabaseClient
          .from('comments')
          .select('*')
          .eq('blog_id', blogId);
      return comments.map((comment) => CommentModel.fromJson(comment)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      return await supabaseClient.from('comments').delete().eq('id', commentId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CommentModel> updateComment(CommentModel comment) async {
    try {
      final commentData = await supabaseClient
          .from('comments')
          .update(comment.toJson())
          .eq('id', comment.id)
          .select();
      return CommentModel.fromJson(commentData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
