import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';

class VerifyEmailPage extends StatelessWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const VerifyEmailPage());

  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Your Email"),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthEmailVerifiedSuccess) {
            // Redirect to the blog page when email is verified
            Navigator.of(context).pushReplacementNamed(
                '/blog'); // Update '/blog' with your blog page route name
          } else if (state is AuthFailure) {
            showSnackBar(context, state.message, isError: true);
          } else if (state is AuthEmailNotVerified) {
            // Optionally, provide additional feedback or instructions
            showSnackBar(context,
                'Your email is not verified yet. Please check your email and verify.');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "A verification email has been sent to your email address. Please verify your email before proceeding.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<AuthBloc>()
                        .add(AuthResendVerificationEmail(email: email));
                    showSnackBar(context, 'Verification email resent.');
                  },
                  child: const Text('Resend Verification Email'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthCheckEmailVerified());
                  },
                  child: const Text('I Have Verified'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
