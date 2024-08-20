import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_field.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const AccountPage());
}

class _AccountPageState extends State<AccountPage> {
  late TextEditingController _userNameController;
  late TextEditingController _userEmailController;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userName =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.name;
    final userEmail =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.email;

    _userNameController = TextEditingController(text: userName);
    _userEmailController = TextEditingController(text: userEmail);
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Username",
              style: TextStyle(
                  fontSize: 20,
                  color: AppPallete.gradient2,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AuthField(
              hintText: "Enter your username",
              controller: _userNameController,
            ),
            const SizedBox(height: 16),
            const Text(
              "Email",
              style: TextStyle(
                  fontSize: 20,
                  color: AppPallete.gradient2,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AuthField(
              hintText: "Enter your email",
              controller: _userEmailController,
            ),
            //const Text(
            //  "Old Password",
            //  style: TextStyle(
            //      fontSize: 20,
            //      color: AppPallete.gradient2,
            //      fontWeight: FontWeight.bold),
            //),

            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Old Password",
                  style: TextStyle(
                      fontSize: 20,
                      color: AppPallete.gradient2,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "New Password",
                  style: TextStyle(
                      fontSize: 20,
                      color: AppPallete.gradient2,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AuthField(
                    hintText: "Enter your old password",
                    controller: _oldPasswordController,
                    obscureText: true,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: AuthField(
                    hintText: "Enter your new password",
                    controller: _newPasswordController,
                    obscureText: true,
                  ),
                ),
              ],
            ),
            //const Text(
            //  "New Password",
            //  style: TextStyle(
            //      fontSize: 20,
            //      color: AppPallete.gradient2,
            //      fontWeight: FontWeight.bold),
            //),
            const SizedBox(height: 30),
            Center(
              child: AuthGradientButton(
                  text: 'Save Changes', onPressed: () => print("tap!")),
            )
          ],
        ),
      ),
    );
  }
}
