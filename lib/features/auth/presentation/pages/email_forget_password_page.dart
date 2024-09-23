import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:blogapp/features/auth/presentation/pages/pincode_page.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_field.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailForgetPasswordPage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const EmailForgetPasswordPage(),
      );
  const EmailForgetPasswordPage({super.key});

  @override
  State<EmailForgetPasswordPage> createState() =>
      _EmailForgetPasswordPageState();
}

class _EmailForgetPasswordPageState extends State<EmailForgetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccessMessage) {
            showSnackBar(context, state.message);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PincodePage(email: _emailController.text)),
            );
          } else if (state is AuthFailure) {
            showSnackBar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter your email address',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 20),
                AuthField(
                  hintText: 'Email Address',
                  controller: _emailController,
                  obscureText: false,
                ),
                SizedBox(height: 30),
                state is AuthLoading
                    ? const Loader()
                    : AuthGradientButton(
                        text: 'Send Reset Link',
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                AuthSendPasswordReset(
                                    email: _emailController.text),
                              );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
