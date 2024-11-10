import 'package:flutter/material.dart';
import 'package:blogapp/core/themes/app_pallete.dart';

void showOptions({
  required BuildContext context,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  String? commentId, // Optional parameter
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppPallete.backgroundColor,
    builder: (context) {
      return SafeArea(
        child: Wrap(
          children: [
            if (onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    },
  );
}

