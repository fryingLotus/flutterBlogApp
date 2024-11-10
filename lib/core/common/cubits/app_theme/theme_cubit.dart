import 'package:blogapp/core/themes/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_state.dart'; // Import your ThemeState

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(ThemeState(
          themeData: AppTheme.darkThemeMode, // Default to dark theme
          themeMode: ThemeModeType.dark,
        ));

  // Method to toggle between light and dark themes
  void toggleTheme() {
    if (state.themeMode == ThemeModeType.dark) {
      emit(ThemeState(
        themeData: AppTheme.lightThemeMode,
        themeMode: ThemeModeType.light,
      ));
    } else {
      emit(ThemeState(
        themeData: AppTheme.darkThemeMode,
        themeMode: ThemeModeType.dark,
      ));
    }
  }
}
