import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. The provider that the UI will watch
//    (Use 'NotifierProvider' instead of 'StateNotifierProvider')
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

// 2. The class (Notifier) that holds the logic
//    (Extend 'Notifier' instead of 'StateNotifier')
class ThemeNotifier extends Notifier<ThemeMode> {
  // 3. The 'build' method is used to set the *initial* state
  //    (This replaces the 'super(ThemeMode.system)' call)
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  // Method to toggle the theme
  void toggleTheme() {
    // 4. The 'state' property is automatically available in 'Notifier'
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }
}
