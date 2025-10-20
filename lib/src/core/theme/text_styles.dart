import 'package:flutter/material.dart';
import 'package:suzy/src/core/theme/colors.dart';

/// Defines all text styles for the Suzy app, using the Poppins font
/// and the custom color palette.
class AppTextStyles {
  // This class is not meant to be instantiated.
  AppTextStyles._();

  /// The font family name declared in pubspec.yaml
  static const String _fontFamily = 'Poppins';

  // --- Base Text Style Definitions ---

  /// Base style for the light theme, using the specified light text color.
  static const TextStyle _baseLight = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.text_light,
    fontWeight: FontWeight.w400, // Regular weight
  );

  /// Base style for the dark theme, using the specified dark text color.
  static const TextStyle _baseDark = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.text_dark,
    fontWeight: FontWeight.w400, // Regular weight
  );

  // --- Material Design Text Themes ---

  /// The complete text theme for the LIGHT mode of the app.
  static TextTheme get lightTextTheme => TextTheme(
    // For very large, important text
    displayLarge: _baseLight.copyWith(
      fontSize: 57,
      fontWeight: FontWeight.w800,
    ),
    displayMedium: _baseLight.copyWith(
      fontSize: 45,
      fontWeight: FontWeight.w700,
    ),
    displaySmall: _baseLight.copyWith(
      fontSize: 36,
      fontWeight: FontWeight.w600,
    ),

    // For headlines, larger than titles
    headlineLarge: _baseLight.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: _baseLight.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: _baseLight.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w500,
    ),

    // For titles of sections, app bars, etc.
    titleLarge: _baseLight.copyWith(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: _baseLight.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: _baseLight.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),

    // For main body content
    bodyLarge: _baseLight.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: _baseLight.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: _baseLight.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),

    // For buttons and other labels
    labelLarge: _baseLight.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
    ),
    labelMedium: _baseLight.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.0,
    ),
    labelSmall: _baseLight.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5,
    ),
  );

  /// The complete text theme for the DARK mode of the app.
  static TextTheme get darkTextTheme => TextTheme(
    // For very large, important text
    displayLarge: _baseDark.copyWith(fontSize: 57, fontWeight: FontWeight.w800),
    displayMedium: _baseDark.copyWith(
      fontSize: 45,
      fontWeight: FontWeight.w700,
    ),
    displaySmall: _baseDark.copyWith(fontSize: 36, fontWeight: FontWeight.w600),

    // For headlines, larger than titles
    headlineLarge: _baseDark.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: _baseDark.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: _baseDark.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w500,
    ),

    // For titles of sections, app bars, etc.
    titleLarge: _baseDark.copyWith(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: _baseDark.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: _baseDark.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),

    // For main body content
    bodyLarge: _baseDark.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: _baseDark.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: _baseDark.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),

    // For buttons and other labels
    labelLarge: _baseDark.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
    ),
    labelMedium: _baseDark.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.0,
    ),
    labelSmall: _baseDark.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5,
    ),
  );
}
