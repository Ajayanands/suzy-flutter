import 'package:flutter/material.dart';
import 'package:suzy/src/core/theme/colors.dart';
import 'package:suzy/src/core/theme/text_styles.dart';

/// Combines all theme elements (colors, text, etc.) into a cohesive app theme.
class AppTheme {
  AppTheme._();

  /// --- Light Theme Definition ---
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      // FIX 1: Use the public font family name directly
      fontFamily: 'Poppins',

      // Set the main background color for all screens (Scaffolds)
      scaffoldBackgroundColor: AppColors.background_light,

      // Apply the light text theme
      textTheme: AppTextStyles.lightTextTheme,

      // --- Component Theming ---
      appBarTheme: AppBarTheme(
        // Use a different color for the app bar if you want
        backgroundColor: AppColors.lightSkyBlue,
        // Use a text style that's readable on that color
        titleTextStyle: AppTextStyles.lightTextTheme.headlineSmall?.copyWith(
          color: AppColors.black, // Example: black text on sky blue
        ),
        iconTheme: const IconThemeData(
          color: AppColors.black, // Example: black icons on sky blue
        ),
      ),

      // Set the default icon color for the app
      iconTheme: const IconThemeData(color: AppColors.icon_light, size: 24.0),

      // Define how other components look
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightSkyBlue, // Button background
          foregroundColor: AppColors.black, // Button text/icon color
          textStyle: AppTextStyles.lightTextTheme.labelLarge,
        ),
      ),

      // Define the main color scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.lightSkyBlue, // Main interactive color
        onPrimary: AppColors.black, // Text/icons on top of primary
        secondary: AppColors.icon_light, // Accent color
        onSecondary: AppColors.black, // Text/icons on top of secondary
        error: AppColors.error,
        onError: AppColors.white,
        // FIX 2: 'background' and 'onBackground' are deprecated.
        // We set the main background using scaffoldBackgroundColor.
        surface: AppColors.white, // Color of Cards, Dialogs, etc.
        onSurface: AppColors.black, // Text on top of surfaces
      ),
    );
  }

  /// --- Dark Theme Definition ---
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      // FIX 1: Use the public font family name directly
      fontFamily: 'Poppins',

      // Set the main background color for all screens (Scaffolds)
      scaffoldBackgroundColor: AppColors.background_dark,

      // Apply the dark text theme
      textTheme: AppTextStyles.darkTextTheme,

      // --- Component Theming ---
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.marianBlue,
        titleTextStyle: AppTextStyles.darkTextTheme.headlineSmall?.copyWith(
          color: AppColors.text_dark, // Use your dark text color
        ),
        iconTheme: const IconThemeData(color: AppColors.text_dark),
      ),

      // Set the default icon color for the app
      iconTheme: const IconThemeData(color: AppColors.icon_dark, size: 24.0),

      // Define how other components look
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.marianBlue, // Button background
          foregroundColor: AppColors.text_dark, // Button text/icon color
          textStyle: AppTextStyles.darkTextTheme.labelLarge,
        ),
      ),

      // Define the main color scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.marianBlue, // Main interactive color
        onPrimary: AppColors.text_dark, // Text/icons on top of primary
        secondary: AppColors.icon_dark, // Accent color
        onSecondary: AppColors.text_dark, // Text/icons on top of secondary
        error: AppColors.error,
        onError: AppColors.white,
        // FIX 2 & 3: Remove deprecated properties and add required 'onSurface'.
        surface: AppColors.marianBlue, // Color of Cards, Dialogs, etc.
        onSurface: AppColors.text_dark, // Text on top of surfaces
      ),
    );
  }
}
// FIX 4: Removed extra text that was causing syntax errors