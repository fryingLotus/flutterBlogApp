import 'package:flutter/material.dart';
import 'package:blogapp/core/themes/app_pallete.dart';

class NavigationTile extends StatelessWidget {
  final String title;
  final Widget? profileImage;
  final Widget Function(BuildContext) routeBuilder;

  const NavigationTile({
    super.key,
    required this.title,
    required this.routeBuilder,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => routeBuilder(context),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppPallete.borderColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        margin: const EdgeInsets.only(left: 25, right: 25, top: 10),
        child: Row(
          children: [
            if (profileImage != null) ...[
              profileImage!,
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppPallete.whiteColor,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}

