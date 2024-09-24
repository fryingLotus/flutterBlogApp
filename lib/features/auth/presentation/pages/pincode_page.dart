import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PincodePage extends StatefulWidget {
  final String email;

  const PincodePage({super.key, required this.email});

  @override
  State<PincodePage> createState() => _PincodePageState();
}

class _PincodePageState extends State<PincodePage> {
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _pinCodeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify PIN and Reset Password'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccessMessage) {
            showSnackBar(context, state.message);
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
                  'Enter the PIN sent to your email (${widget.email})',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: AppPallete.backgroundColor,
                    inactiveFillColor: AppPallete.backgroundColor,
                    inactiveColor: AppPallete.borderColor,
                    selectedFillColor: AppPallete.greyColor,
                    selectedColor: AppPallete.borderColor,
                    activeColor: AppPallete.gradient1,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                  controller: _pinCodeController,
                  keyboardType: TextInputType.number,
                  boxShadows: [
                    BoxShadow(
                      offset: const Offset(0, 1),
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    )
                  ],
                  beforeTextPaste: (text) {
                    return true;
                  },
                  onChanged: (value) {},
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: AppPallete.whiteColor),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppPallete.gradient1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppPallete.borderColor),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                state is AuthLoading
                    ? const Loader()
                    : AuthGradientButton(
                        text: 'Reset Password',
                        onPressed: () {
                          if (_pinCodeController.text.length == 6 &&
                              _newPasswordController.text.isNotEmpty) {
                            context.read<AuthBloc>().add(
                                  AuthResetPassword(
                                    email: widget.email,
                                    code: _pinCodeController.text,
                                    password: _newPasswordController.text,
                                  ),
                                );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please fill out all fields')),
                            );
                          }
                        },
                      ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Trigger resend OTP code
                    context
                        .read<AuthBloc>()
                        .add(AuthSendPasswordReset(email: widget.email));
                  },
                  child: const Text(
                    'Resend OTP Code',
                    style: TextStyle(
                      color: AppPallete.whiteColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
