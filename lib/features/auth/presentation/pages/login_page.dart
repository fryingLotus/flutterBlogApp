import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:blogapp/features/auth/presentation/pages/email_forget_password_page.dart';
import 'package:blogapp/features/auth/presentation/pages/signup_page.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_field.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:blogapp/features/blog/presentation/layout/blog_layout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const LoginPage(),
      );

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //void _requestResendVerificationEmail() {
  //  final email = _emailController.text.trim();
  //  if (email.isNotEmpty) {
  //    context.read<AuthBloc>().add(AuthResendVerificationEmail(email: email));
  //  } else {
  //    showSnackBar(context, 'Please enter your email address.', isError: true);
  //  }
  //}

  //void _requestPasswordReset() {
  //  final email = _emailController.text.trim();
  //  if (email.isNotEmpty) {
  //    context.read<AuthBloc>().add(AuthSendPasswordReset(email: email));
  //  } else {
  //    showSnackBar(context, 'Please enter your email address.', isError: true);
  //  }
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Ensures scroll when the keyboard appears
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Form(
            key: formKey,
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  showSnackBar(context, state.message, isError: true);
                } else if (state is AuthSuccess) {
                  Navigator.pushAndRemoveUntil(
                      context, BlogLayoutPage.route(), (route) => false);
                } else if (state is AuthSuccessMessage) {
                  showSnackBar(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Loader();
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80), // Space to allow scrolling down
                    const Text(
                      "Sign In",
                      style:
                          TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    AuthField(
                      hintText: 'Email',
                      controller: _emailController,
                    ),
                    const SizedBox(height: 15),
                    AuthField(
                      hintText: 'Password',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 15),
                    AuthGradientButton(
                      text: 'Sign In',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(AuthLogin(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim()));
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        SignupPage.route(),
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: 'Don\'t have an account?',
                          style: Theme.of(context).textTheme.titleMedium,
                          children: [
                            const WidgetSpan(child: SizedBox(width: 8)),
                            TextSpan(
                              text: 'Sign Up',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: AppPallete.gradient2,
                                      fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context, EmailForgetPasswordPage.route()),
                      child: RichText(
                        text: TextSpan(
                          text: 'Forget your password?',
                          style: Theme.of(context).textTheme.titleMedium,
                          children: [
                            const WidgetSpan(child: SizedBox(width: 8)),
                            TextSpan(
                              text: 'Click here',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: AppPallete.gradient2,
                                      fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
