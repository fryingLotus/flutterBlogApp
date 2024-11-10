import 'package:flutter/material.dart';

class AuthField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  const AuthField(
      {super.key,
      required this.hintText,
      required this.controller,
      this.obscureText = false});

  @override
  _AuthFieldState createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: _toggleVisibility,
              )
            : null,
      ),
      controller: widget.controller,
      obscureText: _obscureText,
      validator: (value) {
        if (value!.isEmpty) {
          return "${widget.hintText} is missing!";
        }
        return null;
      },
    );
  }
}
