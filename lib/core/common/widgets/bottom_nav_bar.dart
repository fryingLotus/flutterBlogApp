import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBottomNavBar extends StatelessWidget {
  final void Function(int) onTabChange;

  const MyBottomNavBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Reduced padding
      decoration: const BoxDecoration(
        color: AppPallete.backgroundColor, // Dark background for the nav bar
        border: Border(
          top: BorderSide(
            color: AppPallete.borderColor,
            width: 1.0, // A slight border at the top for separation
          ),
        ),
      ),
      child: GNav(
        backgroundColor: AppPallete.backgroundColor, // Match the dark theme
        color: AppPallete.greyColor, // Inactive icon color
        activeColor: AppPallete.whiteColor, // Active icon and text color
        tabBackgroundColor: AppPallete.gradient2
            .withOpacity(0.2), // Subtle background for active tab
        tabBorderRadius: 16,
        gap: 8, // Increased space between icon and text
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), // Reduced padding inside each tab
        iconSize: 20, // Smaller icon size
        textStyle: const TextStyle(
          fontSize: 12, // Smaller text size
          fontWeight: FontWeight.w500,
        ),
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Space out tabs
        onTabChange: (value) => onTabChange(value),
        tabs: const [
          GButton(
            icon: Icons.home,
            text: 'Blogs',
          ),
          GButton(
            icon: Icons.search,
            text: 'Search',
          ),
        ],
      ),
    );
  }
}

