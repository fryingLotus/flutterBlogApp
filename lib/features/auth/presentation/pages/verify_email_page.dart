import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_gradient_button.dart';

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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccessMessage) {
          showSnackBar(context, state.message);
        } else if (state is AuthFailure) {
          showSnackBar(context, 'Error: ${state.message}', isError: true);
        }
      },
      builder: (context, state) {
        final appUserState = context.read<AppUserCubit>().state;

        if (appUserState is! AppUserLoggedIn) {
          return const Scaffold(
            body: Loader(),
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
                  state is AuthLoading
                      ? const Loader()
                      : AuthGradientButton(
                          text: 'Resend Verification Email',
                          onPressed: () {
                            // Trigger event to resend the verification email
                            context
                                .read<AuthBloc>()
                                .add(AuthResendVerificationEmail(email: email));
                          },
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

