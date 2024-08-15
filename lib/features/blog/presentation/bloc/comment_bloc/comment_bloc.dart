import 'package:blogapp/features/blog/domain/entities/comment.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/get_comments_for_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/upload_comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final UploadComment _uploadComment;
  final GetCommentsForBlog _getCommentsForBlog;

  CommentBloc({
    required UploadComment uploadComment,
    required GetCommentsForBlog getCommentsForBlog,
  })  : _uploadComment = uploadComment,
        _getCommentsForBlog = getCommentsForBlog,
        super(CommentInitial()) {
    on<CommentUpload>(_onCommentUpload);
    on<CommentFetchAllForBlog>(_onGetCommentsForBlog);
  }

  void _onCommentUpload(
    CommentUpload event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());

    final result = await _uploadComment(
      UploadCommentParams(
        posterId: event.posterId,
        blogId: event.blogId,
        content: event.content,
      ),
    );

    result.fold(
      (failure) => emit(CommentFailure(failure.message)),
      (success) => emit(CommentUploadSuccess()),
    );
  }

  void _onGetCommentsForBlog(
    CommentFetchAllForBlog event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());

    final result = await _getCommentsForBlog(
        GetCommentsForBlogParams(blogId: event.blogId));

    result.fold(
      (failure) => emit(CommentFailure(failure.message)),
      (comments) => emit(CommentsDisplaySuccess(comments: comments)),
    );
  }
}

