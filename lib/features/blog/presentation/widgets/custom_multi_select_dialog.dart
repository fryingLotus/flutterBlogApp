import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:blogapp/features/blog/domain/entities/topic.dart';

class CustomMultiSelectDialog extends StatelessWidget {
  final List<Topic> allTopics;
  final List<Topic> selectedTopics;
  final Function(List<Topic>) onConfirm;
  final String title;

  const CustomMultiSelectDialog({
    Key? key,
    required this.allTopics,
    required this.selectedTopics,
    required this.onConfirm,
    this.title = "Please select topics to filter",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiSelectDialog(
      title: Text(
        title,
        style: const TextStyle(color: AppPallete.whiteColor),
      ),
      items: allTopics.map((e) => MultiSelectItem(e, e.name)).toList(),
      initialValue: selectedTopics,
      onConfirm: (values) {
        final selectedTopics = values.map((e) => e as Topic).toList();
        onConfirm(selectedTopics);
      },
      backgroundColor: AppPallete.backgroundColor,
      selectedColor: AppPallete.gradient2,
      unselectedColor: AppPallete.borderColor,
      itemsTextStyle: const TextStyle(color: AppPallete.whiteColor),
      selectedItemsTextStyle: const TextStyle(color: AppPallete.whiteColor),
      searchHintStyle: const TextStyle(color: AppPallete.greyColor),
      searchTextStyle: const TextStyle(color: AppPallete.whiteColor),
      checkColor: AppPallete.whiteColor,
      confirmText:
          const Text('Confirm', style: TextStyle(color: AppPallete.whiteColor)),
      cancelText:
          const Text('Cancel', style: TextStyle(color: AppPallete.whiteColor)),
      height: 400,
      width: 300,
    );
  }
}

