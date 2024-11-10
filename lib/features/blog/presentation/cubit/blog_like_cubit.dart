import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

part 'blog_like_state.dart';

class BlogLikeCubit extends Cubit<BloglikecubitState> {
  final String blogId;
  final Box<bool> _likesBox;

  BlogLikeCubit({required this.blogId, required Box<bool> likesBox})
      : _likesBox = likesBox,
        super(BloglikecubitInitial());

  void checkIfLiked() {
    final isLiked = _likesBox.get(blogId, defaultValue: false) ?? false;
    emit(BlogLiked(isLiked: isLiked));
  }

  void toggleLike() async {
    try {
      emit(BlogLikeInProgress());
      final isLiked = _likesBox.get(blogId, defaultValue: false) ?? false;
      final newIsLiked = !isLiked;
      _likesBox.put(blogId, newIsLiked);
      emit(BlogLiked(isLiked: newIsLiked));
    } catch (e) {
      emit(BlogLikeError(message: 'Failed to toggle like: $e'));
    }
  }
}
