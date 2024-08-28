import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String blogPosterId; // Corrected the variable name

  const ChatPage({super.key, required this.blogPosterId}); // Updated constructor

  static route(String blogPosterId) => MaterialPageRoute(
        builder: (context) => ChatPage(
          blogPosterId: blogPosterId, // Pass blogPosterId correctly
        ),
      );

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat for Blog Poster ${widget.blogPosterId}"), // Display the blogPosterId
        centerTitle: true,
      ),
      body: Center(
        child: Text('Chat content for Blog Poster ID: ${widget.blogPosterId}'), // Updated variable
      ),
    );
  }
}

