import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

// Import your custom colors if needed for specific overrides,
// otherwise rely on Theme.of(context)
import 'package:suzy/src/core/theme/colors.dart';

class AppSidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    // --- UPDATED: Use theme colors ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Use a subtle divider color
    final dividerColor = colorScheme.onSurface.withAlpha(51); // ~20% opacity

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 80 : 250,
      decoration: BoxDecoration(
        // Use surface color for the background
        color: colorScheme.surface,
        border: Border(right: BorderSide(color: dividerColor, width: 1)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Divider(
            height: 1,
            color: dividerColor,
          ), // Use the defined divider color
          Expanded(child: _buildNavMenu()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // --- UPDATED: Use theme colors ---
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    // Color for the title text
    final titleColor = textTheme.headlineMedium?.color ?? colorScheme.onSurface;
    // Color for the toggle icon
    final iconColor = colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      height: 120, // Keep height consistent
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Logo and Title (only visible when expanded)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isCollapsed ? 0 : 1,
            // Use IgnorePointer to prevent interaction when hidden
            child: IgnorePointer(
              ignoring: isCollapsed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/SuzyImg.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Suzy",
                    style: textTheme.headlineMedium?.copyWith(
                      color: titleColor, // Use theme text color
                    ),
                    overflow: TextOverflow.ellipsis, // Prevent overflow
                  ),
                ],
              ),
            ),
          ),
          // Toggle Button (always visible)
          Positioned(
            // Adjust position slightly for better centering when collapsed
            top: isCollapsed ? null : 5,
            right: isCollapsed ? null : 10,
            child: IconButton(
              icon: Icon(
                isCollapsed ? LucideIcons.chevronRight : LucideIcons.menu,
                color: iconColor, // Use theme icon color
              ),
              onPressed: onToggle,
              tooltip: isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavMenu() {
    // Keep your menu data structure
    final menuData = [
      {'icon': LucideIcons.layoutDashboard, 'title': 'Dashboard'},
      {'icon': LucideIcons.upload, 'title': 'Upload Notes'},
      {'icon': LucideIcons.folder, 'title': 'Categorize Notes'},
      {'icon': LucideIcons.copy, 'title': 'Flashcards'},
      {'icon': LucideIcons.fileText, 'title': 'Upload Past Test'},
      {'icon': LucideIcons.folderTree, 'title': 'Categorize Past Tests'},
      {'icon': LucideIcons.pencil, 'title': 'Mock Exams'},
      {'icon': LucideIcons.trendingUp, 'title': 'Progress'},
      {'icon': LucideIcons.users, 'title': 'Study Sessions'},
      {'icon': LucideIcons.bot, 'title': 'Chat with Suzy'},
      {'icon': LucideIcons.settings, 'title': 'Settings'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: menuData.length,
      itemBuilder: (context, index) {
        final item = menuData[index];
        return _SidebarMenuItem(
          key: ValueKey(index), // Use index for stable key
          icon: item['icon'] as IconData,
          title: item['title'] as String,
          isSelected: selectedIndex == index,
          isCollapsed: isCollapsed,
          onTap: () => onItemSelected(index),
        );
      },
    );
  }
}

class _SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarMenuItem({
    super.key, // Use super(key: key)
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- UPDATED: Use theme colors ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine colors based on selection and theme
    final Color iconTextColor = isSelected
        ? colorScheme
              .primary // Selected uses primary color
        : isDarkMode
        ? AppColors.white.withAlpha(179) // Dark mode muted
        : AppColors.textSecondary_light; // Light mode muted

    final Color backgroundColor = isSelected
        ? colorScheme.primary.withAlpha(25) // ~10% opacity primary
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Tooltip(
        message: isCollapsed ? title : '',
        waitDuration: const Duration(milliseconds: 300), // Delay tooltip
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: iconTextColor, size: 22),
          title: isCollapsed
              ? null
              : Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    // Use a base style
                    color: iconTextColor,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis, // Prevent text wrapping
                  maxLines: 1,
                ),
          dense: true, // Make items slightly smaller vertically
          contentPadding: isCollapsed
              ? const EdgeInsets.symmetric(
                  horizontal: 16,
                ) // Center icon when collapsed
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }
}
