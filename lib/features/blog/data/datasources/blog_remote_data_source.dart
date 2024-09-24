import 'dart:io';

import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/features/blog/data/models/blog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
  });
  Future<List<BlogModel>> getAllBlogs({int page = 1, int pageSize = 10});

  Future<List<BlogModel>> getBlogsFromFollowedUsers(
      {int page = 1, int pageSize = 10});
  Future<List<BlogModel>> getUserBlogs(String userId);
  Future<void> deleteBlog(String blogId);
  Future<BlogModel> updateBlog(BlogModel blog);
  Future<void> likeBlog(String blogId);
  Future<void> unlikeBlog(String blogId);
}

class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {
  final SupabaseClient supabaseClient;

  BlogRemoteDataSourceImpl(this.supabaseClient);
  @override
  Future<BlogModel> uploadBlog(BlogModel blog) async {
    try {
      final blogData =
          await supabaseClient.from('blogs').insert(blog.toJson()).select();
      return BlogModel.fromJson(blogData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
  }) async {
    try {
      final uniqueId = '${blog.id}_${DateTime.now().millisecondsSinceEpoch}';
      await supabaseClient.storage.from('blogs_image').upload(uniqueId, image);
      return supabaseClient.storage.from('blogs_image').getPublicUrl(uniqueId);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getAllBlogs({int page = 1, int pageSize = 10}) async {
    try {
      final start = (page - 1) * pageSize;
      final end = start + pageSize - 1;

      final blogs = await supabaseClient
          .from('blogs')
          .select('*,profiles (name)')
          .range(start, end);

      return blogs
          .map((blog) => BlogModel.fromJson(blog).copyWith(
                posterName: blog['profiles']['name'],
              ))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getUserBlogs(String userId) async {
    try {
      final blogs = await supabaseClient
          .from('blogs')
          .select('*,profiles (name)')
          .eq('poster_id', userId);
      return blogs
          .map((blog) => BlogModel.fromJson(blog)
              .copyWith(posterName: blog['profiles']['name']))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteBlog(String blogId) async {
    try {
      return await supabaseClient.from('blogs').delete().eq('id', blogId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BlogModel> updateBlog(BlogModel blog) async {
    try {
      final blogData = await supabaseClient
          .from('blogs')
          .update(blog.toJson())
          .eq('id', blog.id)
          .select();

      // Check if blogData is empty before accessing it
      if (blogData.isEmpty) {
        throw Exception('No blog data returned after update.');
      }

      return BlogModel.fromJson(blogData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> likeBlog(String blogId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      print("blogId ${blogId}");
      await supabaseClient.rpc('like_blog_or_comment', params: {
        'p_poster_id': userId,
        'p_blog_id': blogId,
        'p_comment_id': null,
      });
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> unlikeBlog(String blogId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;

      await supabaseClient.rpc('unlike_blog_or_comment', params: {
        'p_poster_id': userId,
        'p_blog_id': blogId,
        'p_comment_id': null,
      });
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getBlogsFromFollowedUsers({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;

      // Fetch the blogs
      final response =
          await supabaseClient.rpc('get_blogs_from_followed_users', params: {
        'current_user_id': userId,
        'page': page,
        'page_size': pageSize,
      });

      // Check if the response is indeed a List<dynamic>
      if (response is List) {
        return response
            .map((blog) => BlogModel.fromJson(blog).copyWith(
                  posterName: blog['poster_name'],
                ))
            .toList();
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
