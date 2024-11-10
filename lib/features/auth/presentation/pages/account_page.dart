import 'package:blogapp/core/common/widgets/navigation_tile.dart';
import 'package:blogapp/features/auth/presentation/pages/subpage/custom_license_page.dart';
import 'package:blogapp/features/auth/presentation/pages/subpage/email_edit_page.dart';
import 'package:blogapp/features/auth/presentation/pages/subpage/password_edit_page.dart';
import 'package:blogapp/features/auth/presentation/pages/subpage/profile_edit_page.dart';
import 'package:blogapp/features/auth/presentation/pages/subpage/username_edit_page.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My Account"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: [
              NavigationTile(
                title: "Username",
                routeBuilder: (context) => const UsernameEditPage(),
              ),
              NavigationTile(
                title: "Email",
                routeBuilder: (context) => const EmailEditPage(),
              ),
              NavigationTile(
                title: "Password",
                routeBuilder: (context) => const PasswordEditPage(),
              ),
              NavigationTile(
                  title: "Profile Picture",
                  routeBuilder: (context) => const ProfileEditPage()),
              NavigationTile(
                  title: "View License",
                  routeBuilder: (context) => const CustomLicensePage()),
            ],
          ),
        ));
  }

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const AccountPage());
}
