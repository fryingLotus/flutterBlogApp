import 'package:flutter/material.dart';

// Enum to define the theme mode (light or dark)
enum ThemeModeType { light, dark }

// Class to represent the state of the theme
class ThemeState {
  final ThemeData themeData; // Holds the current theme data
  final ThemeModeType themeMode; // Holds the current theme mode (light or dark)

  ThemeState({
    required this.themeData,
    required this.themeMode,
  });
}
