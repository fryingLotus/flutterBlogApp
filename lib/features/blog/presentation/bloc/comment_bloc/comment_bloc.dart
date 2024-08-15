import 'package:blogapp/features/blog/domain/usecases/comments/upload_comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final UploadComment _uploadComment; // Use the correct type here

  CommentBloc({
    required UploadComment uploadComment,
  })  : _uploadComment = uploadComment,
        super(CommentInitial()) {
    on<CommentUpload>(_onCommentUpload);
  }

  Future<void> _onCommentUpload(
    CommentUpload event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());

    final result = await _uploadComment( // Directly call the instance
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
}
