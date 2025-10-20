import 'package:flutter/material.dart';

/// Defines the color palette for the Suzy app, based on your specific theme.
class AppColors {
  // This class is not meant to be instantiated.
  AppColors._();

  // --- Light Theme ---

  /// Screen background in light theme (Light Bg Main)
  static const Color background_light = Color(0xFF896C6C);

  /// Default text color in light theme (Light Foreground)
  static const Color text_light = Color(0xFFF5FAE1);

  /// Default icon color in light theme (Light Surface)
  static const Color icon_light = Color(0xFFEEE6CA);

  /// Secondary text color in light theme (Light Text On Surface, Muted Foreground)
  static const Color textSecondary_light = Color(0xFF896C6C);

  /// Extra light theme color (Light Accent)
  static const Color lightSkyBlue = Color(0xFFE5BEB5);

  // --- Dark Theme ---

  /// Screen background in dark theme (Night)
  static const Color background_dark = Color(0xFF0F0F0F);

  /// Default text color in dark theme (Amber)
  static const Color text_dark = Color(0xFFFBC02D);

  /// Default icon color in dark theme (Dartmouth Green)
  static const Color icon_dark = Color(0xFF166534);

  /// Extra dark theme color (Marian Blue)
  static const Color marianBlue = Color(0xFF1E3A8A);

  // --- Common Colors ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color error = Color(0xFFB00020);
}
