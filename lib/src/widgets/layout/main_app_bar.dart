import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dividerColor = colorScheme.onSurface.withAlpha(51);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 80 : 250,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(right: BorderSide(color: dividerColor, width: 1)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Divider(height: 1, color: dividerColor),
          Expanded(child: _buildNavMenu()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final titleColor = textTheme.headlineMedium?.color ?? colorScheme.onSurface;
    final iconColor = colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isCollapsed ? 0 : 1,
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
                      color: titleColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: isCollapsed ? null : 5,
            right: isCollapsed ? null : 10,
            child: IconButton(
              icon: Icon(
                isCollapsed ? LucideIcons.chevronRight : LucideIcons.menu,
                color: iconColor,
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
          key: ValueKey(index),
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
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // --- THIS IS THE FIX ---
    // Define the selection color with a special case for dark mode.
    final Color selectionColor;
    if (isSelected) {
      selectionColor = isDarkMode
          ? AppColors
                .icon_light // Use the light mode's green in dark mode
          : colorScheme.primary; // Use the default primary color in light mode
    } else {
      // Logic for unselected items remains the same
      selectionColor = isDarkMode
          ? AppColors.white.withAlpha(179) // Dark mode muted
          : AppColors.textSecondary_light; // Light mode muted
    }

    // --- UPDATED: The background color now uses the selectionColor logic ---
    final Color backgroundColor = isSelected
        ? selectionColor.withAlpha(
            25,
          ) // ~10% opacity of the correct selection color
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Tooltip(
        message: isCollapsed ? title : '',
        waitDuration: const Duration(milliseconds: 300),
        child: ListTile(
          onTap: onTap,
          // --- UPDATED: Use the new 'selectionColor' for both icon and text ---
          leading: Icon(icon, color: selectionColor, size: 22),
          title: isCollapsed
              ? null
              : Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: selectionColor,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
          dense: true,
          contentPadding: isCollapsed
              ? const EdgeInsets.symmetric(
                  horizontal: 24, // Center icon better when collapsed
                )
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }
}
