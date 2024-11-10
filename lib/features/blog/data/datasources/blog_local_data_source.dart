import 'package:blogapp/features/blog/data/models/blog_model.dart';
import 'package:hive_ce/hive.dart';

abstract interface class BlogLocalDataSource {
  void uploadLocalBlog({required List<BlogModel> blogs});
  List<BlogModel> loadBlogs();
}

class BlogLocalDataSourceImpl implements BlogLocalDataSource {
  final Box box;

  BlogLocalDataSourceImpl(this.box);

  @override
  List<BlogModel> loadBlogs() {
    List<BlogModel> blogs = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.get(i.toString());
      if (data != null) {
        blogs.add(BlogModel.fromJson(data));
      }
    }
    return blogs;
  }

  @override
  void uploadLocalBlog({required List<BlogModel> blogs}) {
    box.clear(); // Clears existing data
    for (int i = 0; i < blogs.length; i++) {
      box.put(i.toString(), blogs[i].toJson()); // Writes each blog entry
    }
  }
}

