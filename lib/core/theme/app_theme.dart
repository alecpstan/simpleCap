import 'package:flutter/material.dart';

/// Application theme configuration.
///
/// Design language: Material 3 with indigo seed color.
/// Follows the established Simple Cap visual style.
class AppTheme {
  AppTheme._();

  /// Light theme configuration.
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      inputDecorationTheme: _inputDecorationTheme,
    );
  }

  /// Dark theme configuration.
  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      inputDecorationTheme: _inputDecorationTheme,
    );
  }

  /// Consistent input decoration across the app.
  static const InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(),
      );
}
