import 'package:blogapp/core/themes/app_pallete.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static _border([
    Color color = AppPallete.borderColor,
  ]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: 3),
      );

  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    appBarTheme: const AppBarTheme(backgroundColor: AppPallete.backgroundColor),
    chipTheme: const ChipThemeData(
        backgroundColor: AppPallete.backgroundColor, side: BorderSide.none),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(28),
      enabledBorder: _border(),
      border: _border(),
      focusedBorder: _border(AppPallete.gradient2),
      errorBorder: _border(AppPallete.errorColor),
    ),
  );

  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
    chipTheme: const ChipThemeData(
        backgroundColor: Colors.white, side: BorderSide.none),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(28),
      enabledBorder: _border(Colors.grey),
      border: _border(Colors.grey),
      focusedBorder: _border(AppPallete.gradient3),
      errorBorder: _border(AppPallete.errorColor),
    ),
  );
}

