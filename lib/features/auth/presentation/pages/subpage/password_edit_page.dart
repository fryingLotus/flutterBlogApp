import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_field.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PasswordEditPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const PasswordEditPage());
  const PasswordEditPage({super.key});

  @override
  State<PasswordEditPage> createState() => _PasswordEditPageState();
}

class _PasswordEditPageState extends State<PasswordEditPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _oldPasswordController.dispose();
    super.dispose();
  }

  void _savePassword() {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    if (oldPassword.isNotEmpty || newPassword.isNotEmpty) {
      context.read<AuthBloc>().add(AuthChangePassword(
          oldPassword: oldPassword, newPassword: newPassword));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showSnackBar(context, state.message, isError: true);
            } else if (state is AuthSuccessMessage) {
              Navigator.pop(context);

              showSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                AuthField(
                  hintText: "Enter your old password",
                  controller: _oldPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: 16.0),
                AuthField(
                  hintText: "Enter your new password",
                  controller: _newPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                AuthGradientButton(
                  text: 'Save Password',
                  onPressed: _savePassword,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
