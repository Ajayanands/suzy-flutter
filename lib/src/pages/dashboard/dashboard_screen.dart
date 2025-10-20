import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- UPDATED Imports ---
import 'package:suzy/src/core/theme/theme_provider.dart'; // Your theme provider
import 'package:suzy/src/pages/landing/landing_screen.dart'; // Landing screen
import 'package:suzy/src/widgets/layout/main_app_bar.dart'; // Your sidebar widget
import 'package:suzy/src/pages/note/notes_upload_screen.dart'; // Example page
// You'll need to create or import this card widget
import 'package:suzy/src/pages/dashboard/dashboard_widget.dart'; // Assuming you have this

// --- UPDATED: Use ConsumerStatefulWidget ---
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  // --- UPDATED: Use ConsumerState ---
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

// --- UPDATED: Use ConsumerState ---
class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isSidebarCollapsed = false;
  int _selectedIndex = 0;
  String? _username; // To hold the fetched username

  // This function will be passed down to the child pages to handle navigation
  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // The list of pages is built in initState to pass the callback.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _fetchUsername(); // Fetch the user's name on load
    _pages = [
      // Pass the navigation function to the dashboard home page
      _DashboardHomePage(onCardTapped: _navigateToPage), // Index 0
      const UploadNotesScreen(), // Index 1 - Assuming this exists
      // --- Placeholder Pages ---
      // Replace these with your actual page widgets as you build them
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

  // Function to get the username from Firestore
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
      // Handle error, maybe set a default name
      if (mounted) {
        setState(() {
          _username = "User"; // Fallback name
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Get theme details ---
    final theme = Theme.of(context);

    return Scaffold(
      // Use scaffold background color from the theme
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
            onItemSelected: _navigateToPage, // Sidebar uses the same function
          ),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(theme), // Pass theme
                Expanded(
                  // Apply padding around the main content area
                  child: Padding(
                    padding: const EdgeInsets.all(
                      16.0,
                    ), // Adjust padding as needed
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

  // --- UPDATED: _buildAppBar uses theme and Riverpod's ref ---
  Widget _buildAppBar(ThemeData theme) {
    final themeMode = ref.watch(themeProvider); // Watch the theme provider
    final isDarkMode = themeMode == ThemeMode.dark;
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Determine icon color based on theme settings
    final iconColor = theme.iconTheme.color ?? colorScheme.onSurface;
    // Determine text color based on theme settings
    final textColor = textTheme.bodyLarge?.color ?? colorScheme.onSurface;

    return Container(
      // Add a subtle bottom border to separate from content
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withAlpha(51), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        // Push content to the right
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              isDarkMode ? LucideIcons.sun : LucideIcons.moon,
              color: iconColor, // Use theme icon color
            ),
            onPressed: () {
              // Read the notifier and call the toggle method
              ref.read(themeProvider.notifier).toggleTheme();
            },
            tooltip: 'Toggle Theme',
            splashRadius: 20, // Smaller splash effect
          ),
          const SizedBox(width: 24),
          // Use the fetched username for a personalized greeting
          Text(
            'Welcome, ${_username ?? 'User'}!',
            // Use theme text color
            style: textTheme.titleMedium?.copyWith(color: textColor),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              LucideIcons.logOut,
              color: iconColor,
            ), // Use theme icon color
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                // Navigate back to landing screen after sign out
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (ctx) => const LandingScreen()),
                  (route) => false,
                );
              }
            },
            tooltip: 'Sign Out',
            splashRadius: 20, // Smaller splash effect
          ),
        ],
      ),
    );
  }
}

// The _DashboardHomePage widget (assuming DashboardCard uses theme)
class _DashboardHomePage extends StatelessWidget {
  final Function(int) onCardTapped;

  // Added key parameter
  const _DashboardHomePage({required this.onCardTapped, super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme for potential card styling (if needed inside this widget)
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid layout
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 1100) {
          // Adjusted breakpoint
          crossAxisCount = 3;
        } else {
          crossAxisCount = 4;
        }

        // Use SingleChildScrollView if content might overflow vertically
        return SingleChildScrollView(
          // Removed padding here, added it around the _pages in build method
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap:
                true, // Important for GridView inside SingleChildScrollView
            physics:
                const NeverScrollableScrollPhysics(), // GridView shouldn't scroll itself
            childAspectRatio: 1.2, // Adjust card aspect ratio if needed
            children: [
              // Assuming DashboardCard is already theme-aware
              DashboardCard(
                icon: LucideIcons.upload,
                title: 'Upload Notes',
                subtitle: 'Organize your materials.',
                onTap: () => onCardTapped(1),
              ),
              DashboardCard(
                icon: LucideIcons.tags, // Changed icon for variety
                title: 'Categorize Notes',
                subtitle: 'Find content easily.',
                onTap: () => onCardTapped(2),
              ),
              DashboardCard(
                icon: LucideIcons.copy, // Moved Flashcards earlier
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
                icon: LucideIcons.trendingUp, // Moved Progress earlier
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
