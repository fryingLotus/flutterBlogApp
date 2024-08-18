import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/features/blog/data/models/comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class CommentRemoteDataSource {
  Future<CommentModel> uploadComment(CommentModel comment);
  Future<List<CommentModel>> getCommentsForBlog(String blogId,
      {int page, int pageSize});
  Future<void> deleteComment(String commentId);
  Future<CommentModel> updateComment(CommentModel comment);
  Future<CommentModel> getCommentById(String commentId);
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
  Future<List<CommentModel>> getCommentsForBlog(String blogId,
      {int page = 1, int pageSize = 10}) async {
    try {
      final from = (page - 1) * pageSize;
      final to = from + pageSize - 1;

      final comments = await supabaseClient
          .from('comments')
          .select('*,profiles (name,avatar_url)')
          .eq('blog_id', blogId)
          .order('created_at', ascending: false)
          .range(from, to);

      return comments
          .map((comment) => CommentModel.fromJson(comment).copyWith(
              posterName: comment['profiles']['name'],
              posterAvatar: comment['profiles']['avatar_url']))
          .toList();
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

  @override
  Future<CommentModel> getCommentById(String commentId) async {
    try {
      final commentData = await supabaseClient
          .from('comments')
          .select()
          .eq('id', commentId)
          .single();

      return CommentModel.fromJson(commentData);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
