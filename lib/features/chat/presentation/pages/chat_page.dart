import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/chat/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String blogPosterId;

  const ChatPage({super.key, required this.blogPosterId});

  static route(String blogPosterId) => MaterialPageRoute(
        builder: (context) => ChatPage(
          blogPosterId: blogPosterId,
        ),
      );

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat for Blog Poster ${widget.blogPosterId}"),
        centerTitle: true,
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatFailure) {
            showSnackBar(context, state.error, isError: true);
          } else if (state is ChatMessageUploadSuccess) {
            _messageController.clear();
            showSnackBar(context, "Message send successfully");
          }
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Loader();
          }
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                      'Chat content for Blog Poster ID: ${widget.blogPosterId}'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Enter your message',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        final String recipientId = (context
                                .read<AppUserCubit>()
                                .state as AppUserLoggedIn)
                            .user
                            .id;
                        final messageContent = _messageController.text.trim();
                        if (messageContent.isNotEmpty) {
                          context.read<ChatBloc>().add(
                                ChatUploadMessage(
                                  conversationId: const Uuid()
                                      .v1(), // replace with actual conversationId
                                  posterId: widget.blogPosterId,
                                  recipientId:
                                      recipientId, // replace with actual recipientId
                                  content: messageContent,
                                ),
                              );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

