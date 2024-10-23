import 'package:blogapp/features/blog/domain/entities/comment.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/delete_comment.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/get_comments_for_blog.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/like_comment.dart';
import 'package:blogapp/features/blog/domain/usecases/comments/unlike_comment.dart';
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
  final LikeComment _likeComment;
  final UnlikeComment _unlikeComment;

  List<Comment>? _comments;

  CommentBloc({
    required UploadComment uploadComment,
    required GetCommentsForBlog getCommentsForBlog,
    required DeleteComment deleteComment,
    required UpdateComment updateComment,
    required LikeComment likeComment,
    required UnlikeComment unlikeComment,
  })  : _uploadComment = uploadComment,
        _deleteComment = deleteComment,
        _getCommentsForBlog = getCommentsForBlog,
        _updateComment = updateComment,
        _likeComment = likeComment,
        _unlikeComment = unlikeComment,
        super(CommentInitial()) {
    on<CommentUpload>(_onCommentUpload);
    on<CommentFetchAllForBlog>(_onGetCommentsForBlog);
    on<CommentDelete>(_onDeleteComment);
    on<CommentUpdate>(_onUpdateComment);
    on<CommentLike>(_onLikeComment);
    on<CommentUnlike>(_onUnlikeComment);
  }

  void _onCommentUpload(CommentUpload event, Emitter<CommentState> emit) async {
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
      CommentFetchAllForBlog event, Emitter<CommentState> emit) async {
    if (state is CommentsDisplaySuccess && event.page > 1) {
      emit(CommentLoadingMore(
          comments: (state as CommentsDisplaySuccess).comments));
    } else {
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
          final currentState = state as CommentsDisplaySuccess;
          final allComments = List<Comment>.from(currentState.comments)
            ..addAll(newComments);
          emit(CommentsDisplaySuccess(
            comments: allComments,
            hasMore: newComments.length == event.pageSize,
          ));
        } else {
          _comments = newComments; // Store the comments
          emit(CommentsDisplaySuccess(
            comments: newComments,
            hasMore: newComments.length == event.pageSize,
          ));
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
      (success) => emit(CommentDeleteSuccess()),
    );
  }

  void _onUpdateComment(CommentUpdate event, Emitter<CommentState> emit) async {
    emit(CommentLoading());

    final res = await _updateComment(UpdateCommentParams(
      commentId: event.commentId,
      content: event.content,
    ));

    res.fold(
      (failure) => emit(CommentFailure(failure.message)),
      (success) => emit(CommentUpdateSuccess()),
    );
  }

  void _onLikeComment(CommentLike event, Emitter<CommentState> emit) async {
    final res =
        await _likeComment(LikeCommentParams(commentId: event.commentId));

    res.fold(
      (failure) => emit(CommentFailure(
        failure.message,
      )),
      (success) {
        _updateLikeStatusAndCount(event.commentId, true, increment: true);
        emit(CommentLikeSuccess(commentId: event.commentId));
        // Emit updated comments state
        if (_comments != null) {
          emit(CommentsDisplaySuccess(
            comments: _comments!,
            hasMore: true,
          ));
        }
      },
    );
  }

  void _onUnlikeComment(CommentUnlike event, Emitter<CommentState> emit) async {
    final res =
        await _unlikeComment(UnlikeCommentParams(commentId: event.commentId));

    res.fold(
      (failure) => emit(CommentFailure(
        failure.message,
      )),
      (success) {
        _updateLikeStatusAndCount(event.commentId, false, increment: false);
        emit(CommentUnlikeSuccess(commentId: event.commentId));
        // Emit updated comments state
        if (_comments != null) {
          emit(CommentsDisplaySuccess(
            comments: _comments!,
            hasMore: true,
          ));
        }
      },
    );
  }

  void _updateLikeStatusAndCount(String commentId, bool isLiked,
      {required bool increment}) {
    _comments = _comments?.map((comment) {
      if (comment.id == commentId) {
        return comment.copyWith(
          isLiked: isLiked,
          likes_count: (comment.likes_count ?? 0) + (increment ? 1 : -1),
        );
      }
      return comment;
    }).toList();
  }
}
