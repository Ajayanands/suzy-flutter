import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- UPDATED Imports ---
import 'package:suzy/src/core/theme/theme_provider.dart';
import 'package:suzy/src/pages/landing/landing_screen.dart';
// --- FIX: Corrected the sidebar import path ---
import 'package:suzy/src/widgets/layout/main_app_bar.dart';
import 'package:suzy/src/pages/note/notes_upload_screen.dart';
import 'package:suzy/src/pages/dashboard/dashboard_widget.dart';

// Use ConsumerStatefulWidget to interact with Riverpod providers
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isSidebarCollapsed = false;
  int _selectedIndex = 0;
  String? _username;

  // Handles navigation from both the sidebar and dashboard cards
  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // The list of pages corresponding to the sidebar menu
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _pages = [
      // Index 0: Main dashboard grid
      _DashboardHomePage(onCardTapped: _navigateToPage),
      // Index 1: The Upload Notes screen is correctly placed here
      const UploadNotesScreen(),
      // --- Placeholder Pages (replace as you build them) ---
      const Center(child: Text('Categorize Notes Page')), // Index 2
      const Center(child: Text('Flashcards Page')), // Index 3
      const Center(child: Text('Upload Past Test Page')), // Index 4
      const Center(child: Text('Categorize Past Tests Page')), // Index 5
      const Center(child: Text('Mock Exams Page')), // Index 6
      const Center(child: Text('Progress Page')), // Index 7
      const Center(child: Text('Study Sessions Page')), // Index 8
      const Center(child: Text('Chat with Suzy Page')), // Index 9
      const Center(child: Text('Settings Page')), // Index 10
    ];
  }

  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted && doc.exists) {
        setState(() {
          _username = doc.data()?['username'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching username: $e");
      if (mounted) {
        setState(() {
          _username = "User"; // Fallback name
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          AppSidebar(
            isCollapsed: _isSidebarCollapsed,
            selectedIndex: _selectedIndex,
            onToggle: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
            onItemSelected: _navigateToPage,
          ),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(theme),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0), // Consistent padding
                    child: _pages[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final iconColor = theme.iconTheme.color ?? colorScheme.onSurface;
    final textColor = textTheme.bodyLarge?.color ?? colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withAlpha(51), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              isDarkMode ? LucideIcons.sun : LucideIcons.moon,
              color: iconColor,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
            tooltip: 'Toggle Theme',
            splashRadius: 20,
          ),
          const SizedBox(width: 24),
          Text(
            'Welcome, ${_username ?? 'User'}!',
            style: textTheme.titleMedium?.copyWith(color: textColor),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(LucideIcons.logOut, color: iconColor),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (ctx) => const LandingScreen()),
                  (route) => false,
                );
              }
            },
            tooltip: 'Sign Out',
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _DashboardHomePage extends StatelessWidget {
  final Function(int) onCardTapped;

  const _DashboardHomePage({required this.onCardTapped});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 1100) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 4;
        }

        return SingleChildScrollView(
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              // This card will now correctly navigate to the UploadNotesScreen
              DashboardCard(
                icon: LucideIcons.upload,
                title: 'Upload Notes',
                subtitle: 'Organize your materials.',
                onTap: () => onCardTapped(1),
              ),
              DashboardCard(
                icon: LucideIcons.tags,
                title: 'Categorize Notes',
                subtitle: 'Find content easily.',
                onTap: () => onCardTapped(2),
              ),
              DashboardCard(
                icon: LucideIcons.copy,
                title: 'Flashcards',
                subtitle: 'Master key concepts.',
                onTap: () => onCardTapped(3),
              ),
              DashboardCard(
                icon: LucideIcons.fileText,
                title: 'Upload Past Test',
                subtitle: 'Store past exam papers.',
                onTap: () => onCardTapped(4),
              ),
              DashboardCard(
                icon: LucideIcons.folderTree,
                title: 'Categorize Past Tests',
                subtitle: 'Assign subjects to your tests.',
                onTap: () => onCardTapped(5),
              ),
              DashboardCard(
                icon: LucideIcons.pencil,
                title: 'Mock Exams',
                subtitle: 'Practice and review.',
                onTap: () => onCardTapped(6),
              ),
              DashboardCard(
                icon: LucideIcons.trendingUp,
                title: 'Progress',
                subtitle: 'Track your study goals.',
                onTap: () => onCardTapped(7),
              ),
              DashboardCard(
                icon: LucideIcons.users,
                title: 'Study Sessions',
                subtitle: 'Collaborate with peers.',
                onTap: () => onCardTapped(8),
              ),
              DashboardCard(
                icon: LucideIcons.bot,
                title: 'Chat with Suzy',
                subtitle: 'Your personal AI assistant.',
                onTap: () => onCardTapped(9),
              ),
              DashboardCard(
                icon: LucideIcons.settings,
                title: 'Settings',
                subtitle: 'Customize your experience.',
                onTap: () => onCardTapped(10),
              ),
            ],
          ),
        );
      },
    );
  }
}
