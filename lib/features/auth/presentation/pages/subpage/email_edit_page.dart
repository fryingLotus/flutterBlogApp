import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_field.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailEditPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const EmailEditPage());
  const EmailEditPage({super.key});

  @override
  State<EmailEditPage> createState() => _EmailEditPageState();
}

class _EmailEditPageState extends State<EmailEditPage> {
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppUserCubit>().state;
    if (state is AppUserLoggedIn) {
      _emailController = TextEditingController(text: state.user.email);
    } else {
      _emailController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _saveEmail() {
    final email = _emailController.text;
    if (email.isNotEmpty) {
      context.read<AuthBloc>().add(AuthUpdate(email: email));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Email")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showSnackBar(context, state.message, isError: true);
            } else if (state is AuthSuccess) {
              showSnackBar(context, "Email updated successfully!");
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                AuthField(
                  hintText: "Enter your new email",
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                AuthGradientButton(
                  text: 'Save Email',
                  onPressed: _saveEmail,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
