import 'package:flutter/material.dart';

class BlogSearchPage extends StatefulWidget {
  const BlogSearchPage({super.key});

  @override
  State<BlogSearchPage> createState() => _BlogSearchPageState();
}

class _BlogSearchPageState extends State<BlogSearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("test"),
      ),
    );
  }
}
