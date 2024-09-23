import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';

class VerifyEmailPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const VerifyEmailPage());

  const VerifyEmailPage({super.key});

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final appUserState = context.read<AppUserCubit>().state;

        // Check if the user is logged in and user data is available
        if (appUserState is! AppUserLoggedIn) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final email = appUserState.user.email;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Verify Email'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Email: $email'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger event to check if the email is verified
                      context.read<AuthBloc>().add(AuthCheckEmailVerified());
                    },
                    child: const Text('Check Email Verification'),
                  ),
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthEmailVerifiedSuccess) {
                        showSnackBar(context, 'Email verification successful!');
                      } else if (state is AuthEmailNotVerified) {
                        showSnackBar(
                            context, 'Email is not verified. Please verify.',
                            isError: true);
                      } else if (state is AuthFailure) {
                        showSnackBar(context, 'Error: ${state.message}',
                            isError: true);
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

