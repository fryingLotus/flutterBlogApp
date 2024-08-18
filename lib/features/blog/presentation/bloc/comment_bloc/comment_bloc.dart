import 'package:blogapp/features/blog/domain/entities/comment.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/delete_comment.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/get_comments_for_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/update_comment.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/upload_comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final UploadComment _uploadComment;
  final GetCommentsForBlog _getCommentsForBlog;
  final DeleteComment _deleteComment;
  final UpdateComment _updateComment;

  CommentBloc({
    required UploadComment uploadComment,
    required GetCommentsForBlog getCommentsForBlog,
    required DeleteComment deleteComment,
    required UpdateComment updateComment,
  })  : _uploadComment = uploadComment,
        _deleteComment = deleteComment,
        _getCommentsForBlog = getCommentsForBlog,
        _updateComment = updateComment,
        super(CommentInitial()) {
    on<CommentUpload>(_onCommentUpload);
    on<CommentFetchAllForBlog>(_onGetCommentsForBlog);
    on<CommentDelete>(_onDeleteComment);
    on<CommentUpdate>(_onUpdateComment);
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
    if (state is CommentsDisplaySuccess && event.page > 1) {
      // Loading more comments for pagination
      emit(CommentLoadingMore(
          comments: (state as CommentsDisplaySuccess).comments));
    } else {
      // Loading initial comments
      emit(CommentLoading());
    }

    final result = await _getCommentsForBlog(
      GetCommentsForBlogParams(
        blogId: event.blogId,
        page: event.page,
        pageSize: event.pageSize,
      ),
    );

    result.fold(
      (failure) => emit(CommentFailure(failure.message)),
      (newComments) {
        if (state is CommentsDisplaySuccess && event.page > 1) {
          // Appending new comments to the existing list
          final currentState = state as CommentsDisplaySuccess;
          final allComments = List<Comment>.from(currentState.comments)
            ..addAll(newComments);
          emit(CommentsDisplaySuccess(
              comments: allComments,
              hasMore: newComments.length == event.pageSize));
        } else {
          // Displaying the first page of comments
          emit(CommentsDisplaySuccess(
              comments: newComments,
              hasMore: newComments.length == event.pageSize));
        }
      },
    );
  }

  void _onDeleteComment(CommentDelete event, Emitter<CommentState> emit) async {
    emit(CommentLoading());
    final res =
        await _deleteComment(DeleteCommentParams(commentId: event.commentId));
    res.fold(
      (failure) => emit(CommentFailure(failure.message)),
      (comments) => emit(CommentDeleteSuccess()),
    );
  }

  void _onUpdateComment(CommentUpdate event, Emitter<CommentState> emit) async {
    emit(CommentLoading());
    final res = await _updateComment(UpdateCommentParams(
        commentId: event.commentId, content: event.content));
    res.fold(
      (failure) => emit(CommentFailure(failure.message)),
      (comments) => emit(CommentUpdateSuccess()),
    );
  }
}
