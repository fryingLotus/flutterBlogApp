import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:blogapp/features/auth/presentation/pages/login_page.dart';
import 'package:blogapp/features/blog/presentation/pages/blog_owned_page.dart';
import 'package:blogapp/features/blog/presentation/widgets/drawer_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // void logout(BuildContext context) {
  //   final _auth = AuthService();
  //   _auth.signOut();
  // }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // header
          const DrawerHeader(
            child: Icon(Icons.note),
          ),
          // note tile
          DrawerTile(
              title: "Home",
              leading: const Icon(Icons.home),
              onTap: () {
                Navigator.pop(context);
              }),
          DrawerTile(
              title: "Your Blogs",
              leading: const Icon(Icons.book),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, BlogOwnedPage.route());
              }),

          // DrawerTile(
          //     title: "Settings",
          //     leading: const Icon(Icons.settings),
          //     onTap: () {
          //       Navigator.pop(context);
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //               builder: (context) => const SettingsPage()));
          //     }),

          // Spacer to push the logout tile to the bottom
          Spacer(),

          // logout tile
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: DrawerTile(
                title: "Logout",
                leading: const Icon(Icons.logout),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  context.read<AuthBloc>().add(AuthLogout());

                  Navigator.pushAndRemoveUntil(
                      context, LoginPage.route(), (route) => false);
                }),
          ),
        ],
      ),
    );
  }
}
