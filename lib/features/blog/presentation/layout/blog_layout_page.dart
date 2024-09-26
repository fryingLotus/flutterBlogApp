import 'package:blogapp/core/common/widgets/bottom_nav_bar.dart';
import 'package:blogapp/features/blog/presentation/pages/blog_page.dart';
import 'package:blogapp/features/blog/presentation/pages/blog_search_page.dart';
import 'package:flutter/material.dart';

class BlogLayoutPage extends StatefulWidget {
  const BlogLayoutPage({super.key});

  @override
  State<BlogLayoutPage> createState() => _BlogLayoutPageState();
}

class _BlogLayoutPageState extends State<BlogLayoutPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    BlogPage(),
    BlogSearchPage(),
    // Add more pages here as needed
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: _onItemTapped,
      ),
    );
  }
}

