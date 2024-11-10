import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:flutter/material.dart';

class AuthGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const AuthGradientButton(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(colors: [
            AppPallete.gradient1,
            AppPallete.gradient2,
            //AppPallete.gradient3,
          ], begin: Alignment.bottomLeft, end: Alignment.topRight)),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            fixedSize: const Size(395, 55),
            backgroundColor: AppPallete.transparentColor,
            shadowColor: AppPallete.transparentColor),
        child: Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
