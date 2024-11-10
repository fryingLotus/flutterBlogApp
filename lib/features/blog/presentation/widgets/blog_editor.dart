import 'package:flutter/material.dart';

class BlogEditor extends StatelessWidget {
  final TextEditingController controller;
  final Icon? suffixIcon;
  final VoidCallback? onSuffixIconPressed; // Optional callback for icon press
  final String hintText;

  const BlogEditor({
    super.key,
    required this.controller,
    required this.hintText,
    this.suffixIcon,
    this.onSuffixIconPressed, // Accept the callback here
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 30),
                child: GestureDetector(
                  onTap: onSuffixIconPressed, // Use the callback here
                  child: suffixIcon,
                ),
              )
            : null,
      ),
      maxLines: null,
      validator: (value) {
        if (value!.trim().isEmpty) {
          return '$hintText is missing!';
        }
        return null;
      },
    );
  }
}
