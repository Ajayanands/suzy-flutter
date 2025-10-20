import 'package:flutter/material.dart';
// Import AppColors to potentially use specific colors like the secondary text color
import 'package:suzy/src/core/theme/colors.dart';

class DashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // --- Get theme details ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // --- Define muted text color based on theme ---
    final Color mutedTextColor = isDarkMode
        ? AppColors.white.withAlpha(179) // 70% white for dark mode
        : AppColors.textSecondary_light; // Your specific light secondary color

    // --- Define icon color logic ---
    // Use the primary color on hover, otherwise use the theme's default icon color
    final iconColor = _isHovered
        ? colorScheme.primary
        : theme.iconTheme.color ??
              colorScheme.onSurface; // Fallback to onSurface

    // --- Define border color logic ---
    final borderColor = _isHovered ? colorScheme.primary : Colors.transparent;

    // --- Define shadow color logic ---
    final shadowColor = _isHovered
        ? colorScheme.primary.withAlpha(77) // ~30% opacity
        : theme.shadowColor;

    // --- Define gradient colors for hover effect ---
    final gradientColors = [
      colorScheme.primary.withAlpha(_isHovered ? 26 : 0), // ~10% opacity start
      colorScheme.primary.withAlpha(0), // Fades to transparent end
    ];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        // Apply scale transform on hover
        transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
        transformAlignment: Alignment.center,
        child: Card(
          clipBehavior:
              Clip.antiAlias, // Ensures gradient respects border radius
          // Card background uses surface color from theme
          color: colorScheme.surface,
          elevation: _isHovered ? 8 : 1, // Increase elevation on hover
          shadowColor: shadowColor, // Apply dynamic shadow color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Softer corners
            // Apply dynamic border
            side: BorderSide(color: borderColor, width: 1.5),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16), // Match card shape
            child: Container(
              padding: const EdgeInsets.all(24),
              // Apply subtle gradient background on hover
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                // Ensure border radius matches card if needed, though InkWell handles it
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center content vertically
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center content horizontally
                children: [
                  AnimatedScale(
                    scale: _isHovered ? 1.1 : 1.0, // Scale icon on hover
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Icon(
                      widget.icon,
                      size: 36,
                      color: iconColor, // Apply dynamic icon color
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    // Use titleLarge from theme, color is inherited
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600, // Slightly bolder title
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle,
                    // Use bodyMedium but override color with mutedTextColor
                    style: textTheme.bodyMedium?.copyWith(
                      color: mutedTextColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2, // Allow subtitle to wrap slightly
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
