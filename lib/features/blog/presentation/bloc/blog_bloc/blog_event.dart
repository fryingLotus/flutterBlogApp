part of 'blog_bloc.dart';

sealed class BlogEvent {}

final class BlogUpload extends BlogEvent {
  final String posterId;
  final String title;
  final String content;
  final File image;
  final List<Topic> topics;

  BlogUpload({
    required this.posterId,
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });
}

final class BlogUpdate extends BlogEvent {
  final String posterId;
  final String title;
  final String content;
  final File? image; // Make image optional
  final List<Topic> topics;
  final String blogId;
  final String? currentImageUrl; // Optional current image URL

  BlogUpdate({
    required this.posterId,
    required this.title,
    required this.content,
    this.image, // Make optional
    required this.topics,
    required this.blogId,
    this.currentImageUrl, // Add optional current image URL
  });
}

final class BlogFetchAllBlogs extends BlogEvent {
  final int page;
  final int pageSize;
  final List<String>? topicIds;

  BlogFetchAllBlogs({
    this.topicIds,
    required this.page,
    required this.pageSize,
  });
}

final class BlogFetchUserFollowBlogs extends BlogEvent {
  final List<String>? topicIds;
  final int page;
  final int pageSize;

  BlogFetchUserFollowBlogs(
      {this.topicIds, required this.page, required this.pageSize});
}

final class BlogFetchUserBlogs extends BlogEvent {
  final String userId;

  final List<String>? topicIds;

  BlogFetchUserBlogs({this.topicIds, required this.userId});
}

final class BlogFetchBookmarkedBlogs extends BlogEvent {
  final List<String>? topicIds;
  final List<String> blogIds;

  BlogFetchBookmarkedBlogs({this.topicIds, required this.blogIds});
}

final class BlogDelete extends BlogEvent {
  final String blogId;

  BlogDelete({required this.blogId});
}

final class BlogLike extends BlogEvent {
  final String blogId;

  BlogLike({required this.blogId});
}

final class BlogUnlike extends BlogEvent {
  final String blogId;

  BlogUnlike({required this.blogId});
}

final class BlogSearch extends BlogEvent {
  final String title;

  BlogSearch({required this.title});
}

final class BlogFetchAllBlogTopics extends BlogEvent {}
