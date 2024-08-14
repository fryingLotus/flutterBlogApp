import 'package:blogapp/features/blog/presentation/widgets/blog_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class BlogButton extends StatelessWidget {
  final void Function()? onEditTap;
  final void Function()? onDeleteTap;

  const BlogButton({
    super.key,
    this.onEditTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showPopover(
            context: context,
            bodyBuilder: (context) => BlogMenuItem(
                  onEditTap: onEditTap,
                  onDeleteTap: onDeleteTap,
                ),
            width: 250,
            height: 100);
      },
      child: const Icon(Icons.more_vert),
    );
  }
}

