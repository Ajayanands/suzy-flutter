import 'package:flutter/material.dart';

/// Defines the color palette for the Suzy app, based on your specific theme.
class AppColors {
  // This class is not meant to be instantiated.
  AppColors._();

  // --- Light Theme ---

  /// Screen background in light theme
  static const Color background_light = Color(0xFFF5F5F5);

  /// Default text color in light theme
  static const Color text_light = Color(0xFFFFF59D);

  /// Default icon color in light theme
  static const Color icon_light = Color(0xFFA5D6A7);

  /// Extra light theme color (from --light-sky-blue)
  static const Color lightSkyBlue = Color(0xFF90CAF9);

  // --- Dark Theme ---

  /// Screen background in dark theme
  static const Color background_dark = Color(0xFF0F0F0F);

  /// Default text color in dark theme
  static const Color text_dark = Color(0xFFFBC02D);

  /// Default icon color in dark theme
  static const Color icon_dark = Color(0xFF166534);

  /// Extra dark theme color (from --marian-blue)
  static const Color marianBlue = Color(0xFF1E3A8A);

  // --- Common Colors (for reference) ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color error = Color(0xFFB00020);
}
