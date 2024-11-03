import 'package:blogapp/core/common/cubits/app_theme/theme_cubit.dart';
import 'package:blogapp/core/common/cubits/app_theme/theme_state.dart';
import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/pages/follower_page.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:blogapp/features/auth/presentation/pages/login_page.dart';
import 'package:blogapp/features/blog/presentation/layout/blog_layout_page.dart';
import 'package:blogapp/features/blog/presentation/pages/blog_bookmark_page.dart';
import 'package:blogapp/features/blog/presentation/pages/blog_owned_page.dart';
import 'package:blogapp/features/blog/presentation/pages/settings_page.dart';
import 'package:blogapp/features/blog/presentation/widgets/drawer_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyDrawer extends StatelessWidget {
  //final Function(int) onItemSelected;
  const MyDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select(
        (ThemeCubit cubit) => cubit.state.themeMode == ThemeModeType.dark);
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;

    return Drawer(
      backgroundColor: isDarkMode
          ? AppPallete.backgroundColor
          : Colors.white, // Adjust background color based on theme
      child: Column(
        children: [
          // Header
          const DrawerHeader(
            child: Icon(Icons.note),
          ),
          // Note tile
          DrawerTile(
            title: "Home",
            leading: const Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, BlogLayoutPage.route());
            },
          ),
          DrawerTile(
            title: "Your Blogs",
            leading: const Icon(Icons.book),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, BlogOwnedPage.route(userId));
            },
          ),
          DrawerTile(
            title: "Bookmarks",
            leading: const Icon(Icons.bookmark),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, BlogBookmarkPage.route());
            },
          ),
          DrawerTile(
            title: "Settings",
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          DrawerTile(
            title: "Profile",
            leading: const Icon(Icons.verified_user),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FollowerPage(
                          otherId: userId,
                        )),
              );
            },
          ),
          // Spacer to push the logout tile to the bottom
          const Spacer(),
          // Logout tile
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: DrawerTile(
              title: "Logout",
              leading: const Icon(Icons.logout),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(AuthLogout());
                Navigator.pushAndRemoveUntil(
                  context,
                  LoginPage.route(),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
