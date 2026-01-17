import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

const _themeModeKey = 'theme_mode_is_dark';

/// Provides the current theme mode (light or dark).
///
/// Persists the user's preference to SharedPreferences.
/// Defaults to light mode if no preference is stored.
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeModeKey) ?? false;
  }

  /// Toggle between light and dark mode.
  Future<void> toggle() async {
    final currentValue = state.valueOrNull ?? false;
    final newValue = !currentValue;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, newValue);

    state = AsyncData(newValue);
  }

  /// Set dark mode explicitly.
  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, isDark);

    state = AsyncData(isDark);
  }
}

/// Convenient provider that returns ThemeMode based on the stored preference.
@riverpod
ThemeMode themeMode(ThemeModeRef ref) {
  final isDarkAsync = ref.watch(themeModeNotifierProvider);
  final isDark = isDarkAsync.valueOrNull ?? false;
  return isDark ? ThemeMode.dark : ThemeMode.light;
}
