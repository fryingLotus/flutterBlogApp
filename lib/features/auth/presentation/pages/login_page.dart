import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/features/auth/presentation/pages/signup_page.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_field.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => LoginPage());
  LoginPage({super.key});

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

  //void _submitForm() {
  //  if (formKey.currentState!.validate()) {
  //    // Perform the signup logic
  //  }
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Sign In",
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
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
              const SizedBox(
                height: 20,
              ),
              AuthGradientButton(
                text: 'Sign In',
                onPressed: () {},
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, SignupPage.route()),
                child: RichText(
                    text: TextSpan(
                        text: 'Don\'t have an account?',
                        style: Theme.of(context).textTheme.titleMedium,
                        children: [
                      const WidgetSpan(
                          child: SizedBox(
                        width: 8,
                      )),
                      TextSpan(
                          text: 'Sign Up',
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
