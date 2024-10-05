import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_field.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsernameEditPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const UsernameEditPage());
  const UsernameEditPage({super.key});

  @override
  State<UsernameEditPage> createState() => _UsernameEditPageState();
}

class _UsernameEditPageState extends State<UsernameEditPage> {
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _saveUsername() {
    final username = _usernameController.text;
    if (username.isNotEmpty) {
      context.read<AuthBloc>().add(AuthUpdate(name: username));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Username")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showSnackBar(context, state.message, isError: true);
            } else if (state is AuthSuccess) {
              showSnackBar(context, "Username updated successfully!");
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            // Get the current user from AppUserCubit state
            final appUserState = context.watch<AppUserCubit>().state;

            if (appUserState is AppUserLoggedIn) {
              _usernameController.text =
                  appUserState.user.name; // Set the username
            }

            return Column(
              children: [
                AuthField(
                  hintText: "Enter your new username",
                  controller: _usernameController,
                ),
                const SizedBox(height: 20),
                AuthGradientButton(
                  text: 'Save Username',
                  onPressed: _saveUsername,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

