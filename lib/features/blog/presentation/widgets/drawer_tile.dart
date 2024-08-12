import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {
  final String title;
  final Widget leading;
  final void Function()? onTap;
  const DrawerTile(
      {super.key,
      required this.title,
      required this.leading,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: AppPallete.whiteColor),
        ),
        leading: leading,
        onTap: onTap,
      ),
    );
  }
}
