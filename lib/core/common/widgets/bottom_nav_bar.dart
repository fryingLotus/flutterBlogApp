import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBottomNavBar extends StatelessWidget {
  final void Function(int) onTabChange;

  const MyBottomNavBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: GNav(
        color: Colors.grey[400],
        activeColor: Colors.grey.shade700,
        tabBackgroundColor: Colors.grey.shade100,
        mainAxisAlignment: MainAxisAlignment.center,
        tabBorderRadius: 16,
        onTabChange: (value) => onTabChange(value),
        tabs: const [
          GButton(
            icon: Icons.home,
            text: 'Blogs',
          ),
          GButton(
            icon: Icons.search,
            text: 'Search',
          )
        ],
      ),
    );
  }
}

