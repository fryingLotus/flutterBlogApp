import 'package:blogapp/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/core/utils/show_snackbar.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_field.dart';
import 'package:blogapp/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blogapp/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const AccountPage());
}

class _AccountPageState extends State<AccountPage> {
  late TextEditingController _userNameController;
  late TextEditingController _userEmailController;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AppUserCubit>().state;
    if (state is AppUserLoggedIn) {
      _userNameController = TextEditingController(text: state.user.name);
      _userEmailController = TextEditingController(text: state.user.email);
    } else {
      _userNameController = TextEditingController();
      _userEmailController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final name = _userNameController.text;
    final email = _userEmailController.text;
    final password = _passwordController.text;

    context.read<AuthBloc>().add(
          AuthUpdate(
            name: name.isNotEmpty ? name : null,
            email: email.isNotEmpty ? email : null,
            password: password.isNotEmpty ? password : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showSnackBar(context, state.message, isError: true);
            } else if (state is AuthSuccess) {
              showSnackBar(context, "Successfully updated your profile!");
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Loader();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Username",
                  style: TextStyle(
                    fontSize: 20,
                    color: AppPallete.gradient2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AuthField(
                  hintText: "Enter your username",
                  controller: _userNameController,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 20,
                    color: AppPallete.gradient2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AuthField(
                  hintText: "Enter your email",
                  controller: _userEmailController,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Password",
                  style: TextStyle(
                    fontSize: 20,
                    color: AppPallete.gradient2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AuthField(
                  hintText: "Enter your new password",
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                Center(
                  child: AuthGradientButton(
                    text: 'Save Changes',
                    onPressed: _saveChanges,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
