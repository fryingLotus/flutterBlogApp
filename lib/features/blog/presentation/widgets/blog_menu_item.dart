import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:flutter/material.dart';

class BlogMenuItem extends StatelessWidget {
  final void Function()? onEditTap;
  final void Function()? onDeleteTap;

  const BlogMenuItem({
    super.key,
    this.onEditTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Edit item
        GestureDetector(
          onTap: () {
            onEditTap?.call();
            Navigator.pop(context);
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            color: AppPallete.backgroundColor,
            child: const Row(
              children: [
                Icon(Icons.edit, color: Colors.blue),
                SizedBox(width: 8),
                Text("Edit"),
              ],
            ),
          ),
        ),
        // Delete item
        GestureDetector(
          onTap: () {
            onDeleteTap?.call();
            Navigator.pop(context);
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            color: AppPallete.backgroundColor,
            child: const Row(
              children: [
                Icon(Icons.delete, color: Colors.redAccent),
                SizedBox(width: 8),
                Text("Delete"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

