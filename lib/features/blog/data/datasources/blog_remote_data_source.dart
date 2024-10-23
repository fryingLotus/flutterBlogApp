import 'dart:io';
import 'package:blogapp/core/error/exceptions.dart';
import 'package:blogapp/features/blog/data/models/blog_model.dart';
import 'package:blogapp/features/blog/domain/entities/topic.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
  });
  Future<List<BlogModel>> getAllBlogs(
      {List<String>? topicIds, int page = 1, int pageSize = 10});
  Future<List<BlogModel>> getBlogsFromFollowedUsers(
      {List<String>? topicIds, int page = 1, int pageSize = 10});
  Future<List<BlogModel>> getUserBlogs(
      {List<String>? topicIds, required String userId});
  Future<void> deleteBlog(String blogId);
  Future<BlogModel> updateBlog(BlogModel blog);
  Future<void> likeBlog(String blogId);
  Future<void> unlikeBlog(String blogId);
  Future<void> insertBlogTopic(
      {required String blogId, required String topicId});
  Future<List<Topic>> getAllBlogTopics();
  Future<void> updateBlogTopics(String blogId, List<Topic> topics);
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
  Future<List<BlogModel>> getAllBlogs({
    int page = 1,
    int pageSize = 10,
    List<String>? topicIds,
  }) async {
    try {
      final List<String> topicIdArray = topicIds ?? [];
      final response = await supabaseClient.rpc('get_all_blogs', params: {
        'input_topic_ids': topicIdArray.isEmpty ? null : topicIdArray,
        'page': page,
        'page_size': pageSize,
      });

      if (response is List<dynamic>) {
        return response.map<BlogModel>((blog) {
          return BlogModel.fromJson({
            ...blog,
            'topics': (blog['topics'] as List<dynamic>?)
                    ?.map((topic) => topic.toString())
                    .toList() ??
                [],
          });
        }).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getUserBlogs(
      {List<String>? topicIds, required String userId}) async {
    try {
      final List<String> topicIdArray = topicIds ?? [];
      final blogs = await supabaseClient.rpc('get_user_blogs', params: {
        'input_topic_ids': topicIdArray.isEmpty ? null : topicIdArray,
        'user_id': userId,
      });
      //final blogs = await supabaseClient
      //    .from('blogs')
      //    .select('*, profiles (name)')
      //    .eq('poster_id', userId);
      //return blogs
      //    .map((blog) => BlogModel.fromJson(blog)
      //        .copyWith(posterName: blog['profiles']['name']))
      //    .toList();
      if (blogs is List<dynamic>) {
        return blogs.map<BlogModel>((blog) {
          return BlogModel.fromJson({
            ...blog,
            'topics': (blog['topics'] as List<dynamic>?)
                    ?.map((topic) => topic.toString())
                    .toList() ??
                [],
          });
        }).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getBlogsFromFollowedUsers({
    List<String>? topicIds,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;

      final List<String> topicIdArray = topicIds ?? [];
      // Fetch the blogs
      final response =
          await supabaseClient.rpc('get_blogs_from_followed_users', params: {
        'current_user_id': userId,
        'input_topic_ids': topicIdArray.isEmpty ? null : topicIdArray,
        'page': page,
        'page_size': pageSize,
      });

      // Check if the response is indeed a List<dynamic>
      if (response is List<dynamic>) {
        return response.map<BlogModel>((blog) {
          return BlogModel.fromJson({
            ...blog,
            'topics': (blog['topics'] as List<dynamic>?)
                    ?.map((topic) => topic.toString())
                    .toList() ??
                [],
          });
        }).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteBlog(String blogId) async {
    try {
      await supabaseClient.from('blogs').delete().eq('id', blogId);
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
  Future<void> insertBlogTopic({
    required String blogId,
    required String topicId,
  }) async {
    try {
      await supabaseClient.from('blog_topics').insert({
        'blog_id': blogId,
        'topic_id': topicId,
      });
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Topic>> getAllBlogTopics() async {
    try {
      final response = await supabaseClient
          .from('topics')
          .select('id, name')
          .order('name', ascending: true);

      return (response as List<dynamic>).map((topic) {
        return Topic(
          id: topic['id'] as String,
          name: topic['name'] as String,
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateBlogTopics(String blogId, List<Topic> topics) async {
    try {
      await supabaseClient.from('blog_topics').delete().eq('blog_id', blogId);

      final topicEntries = topics.map((topic) {
        return {
          'blog_id': blogId,
          'topic_id': topic.id,
        };
      }).toList();

      await supabaseClient.from('blog_topics').insert(topicEntries);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
