import "package:blogapp/core/themes/app_pallete.dart";
import "package:flutter/material.dart";

class SeparatorWithText extends StatelessWidget {
  const SeparatorWithText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
            child: Divider(
          thickness: 1,
          color: AppPallete.greyColor,
        )),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Or',
            style: TextStyle(color: AppPallete.greyColor, fontSize: 16),
          ),
        ),
        Expanded(
            child: Divider(
          thickness: 1,
          color: AppPallete.greyColor,
        ))
      ],
    );
  }
}

