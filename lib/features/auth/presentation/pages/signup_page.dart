import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:blogapp/features/auth/presentation/pages/login_page.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_field.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => SignupPage());
  SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    formKey.currentState?.validate();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Sign Up",
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              AuthField(
                hintText: 'Name',
                controller: _nameController,
              ),
              const SizedBox(
                height: 15,
              ),
              AuthField(
                hintText: 'Email',
                controller: _emailController,
              ),
              const SizedBox(
                height: 15,
              ),
              AuthField(
                hintText: 'Password',
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(
                height: 15,
              ),
              AuthField(
                hintText: 'Confirm Password',
                controller: _confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(
                height: 20,
              ),
              AuthGradientButton(
                text: 'Sign Up',
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context.read<AuthBloc>().add(AuthSignUp(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                        name: _nameController.text.trim()));
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, LoginPage.route()),
                child: RichText(
                    text: TextSpan(
                        text: 'Already have an account?',
                        style: Theme.of(context).textTheme.titleMedium,
                        children: [
                      const WidgetSpan(
                          child: SizedBox(
                        width: 8,
                      )),
                      TextSpan(
                          text: 'Sign In',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: AppPallete.gradient2,
                                  fontWeight: FontWeight.bold))
                    ])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
