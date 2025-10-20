import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:suzy/src/pages/auth/login_screen.dart';
import 'package:suzy/src/pages/auth/register_screen.dart';
import 'package:suzy/src/core/theme/colors.dart';
import 'package:suzy/src/core/theme/theme_provider.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  bool _isHeaderHeartLiked = false;
  bool _isFooterHeartLiked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildHeroSection(context),
            _buildFeaturesSection(context),
            _buildCtaSection(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // Header Section
  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final iconColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _AnimatedHeartIcon(
                isLiked: _isHeaderHeartLiked,
                size: 24,
                onTap: () {
                  setState(() {
                    _isHeaderHeartLiked = !_isHeaderHeartLiked;
                  });
                },
              ),
              const SizedBox(width: 8),
              Text('Suzy', style: textTheme.headlineMedium),
            ],
          ),
          Row(
            children: [
              IconButton(
                splashRadius: 20,
                icon: Icon(
                  isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                  color: iconColor,
                ),
                onPressed: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDarkMode ? AppColors.text_dark : null,
                  foregroundColor: isDarkMode
                      ? AppColors.background_dark
                      : null,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                  );
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Footer Section
  Widget _buildFooter(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: colorScheme.surface.withAlpha(26),
        border: Border(
          top: BorderSide(color: colorScheme.secondary.withAlpha(51)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AnimatedHeartIcon(
                isLiked: _isFooterHeartLiked,
                size: 24,
                onTap: () {
                  setState(() {
                    _isFooterHeartLiked = !_isFooterHeartLiked;
                  });
                },
              ),
              const SizedBox(width: 8),
              Text('Suzy', style: textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Creating beautiful, inspiring study experiences for every learner.',
            style: textTheme.bodyMedium?.copyWith(
              color: textTheme.bodyMedium?.color?.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Divider(color: colorScheme.secondary.withAlpha(51)),
          const SizedBox(height: 32),
          Text(
            '© 2025 Suzy. Made with heart for learners everywhere.',
            style: textTheme.bodySmall?.copyWith(
              color: textTheme.bodySmall?.color?.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Developed by Ajay Anand, Mai Hazem, Haya Zaheer',
            style: textTheme.bodySmall?.copyWith(
              color: textTheme.bodySmall?.color?.withAlpha(138),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Hero Section
  Widget _buildHeroSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 1024;
        if (isDesktop) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 12, child: _buildHeroImage(context)),
                const SizedBox(width: 64),
                Expanded(flex: 8, child: _buildHeroContent(context)),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                _buildHeroImage(context),
                const SizedBox(height: 32),
                _buildHeroContent(context),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/SuzyLandingPage.png',
            fit: BoxFit.cover,
            height: 600,
            width: double.infinity,
          ),
        ),
        Positioned(
          bottom: -16,
          right: -16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withAlpha(38),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(LucideIcons.leaf, size: 16, color: colorScheme.onPrimary),
                const SizedBox(width: 4),
                Text(
                  'Study in Style',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: textTheme.headlineLarge?.copyWith(fontSize: 48, height: 1.1),
            children: [
              const TextSpan(text: 'Welcome to\n'),
              TextSpan(
                text: 'Suzy',
                style: TextStyle(color: colorScheme.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Create your perfect aesthetic study environment with cozy vibes, productivity tools, and a supportive community that inspires learning.',
          style: textTheme.bodyMedium?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 32),
        _buildSignupCard(context),
      ],
    );
  }

  // RESPONSIVE FIX: "Sign in here" button now wraps on mobile
  Widget _buildSignupCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(40.0),
          decoration: BoxDecoration(
            color: AppColors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.secondary.withAlpha(51)),
          ),
          child: Column(
            children: [
              Text(
                'Start Your Study Journey',
                style: textTheme.titleLarge?.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const RegisterScreen()),
                  );
                },
                child: const Text('Sign Up for Free'),
              ),
              const SizedBox(height: 24),

              // RESPONSIVE: Wrap text + button to prevent overflow
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool isNarrow = constraints.maxWidth < 350;

                  return Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: textTheme.bodyMedium,
                      ),
                      if (!isNarrow) const SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? AppColors.text_dark
                              : null,
                          foregroundColor: isDarkMode
                              ? AppColors.background_dark
                              : null,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign in here',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? AppColors.background_dark
                                : colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Features Section
  Widget _buildFeaturesSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Column(
        children: [
          Text(
            'Everything You Need to Study Better',
            style: textTheme.headlineMedium?.copyWith(fontSize: 40),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: const [
              _FeatureCard(
                icon: LucideIcons.coffee,
                title: 'Cozy Study Vibes',
                description:
                    'Aesthetic study environments designed to keep you motivated and focused during long study sessions.',
              ),
              _FeatureCard(
                icon: LucideIcons.target,
                title: 'Smart Goal Setting',
                description:
                    'Track your progress with beautiful visual goal tracking that makes studying feel rewarding.',
              ),
              _FeatureCard(
                icon: LucideIcons.users,
                title: 'Study Community',
                description:
                    'Connect with like-minded learners in our aesthetic, supportive study community.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Call to Action Section
  Widget _buildCtaSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withAlpha(26),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Fall in Love with Studying?',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(fontSize: 40),
          ),
          const SizedBox(height: 24),
          Text(
            'Join Suzy today and discover how beautiful, organized study spaces can transform your learning experience.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const RegisterScreen()),
              );
            },
            child: const Text('Start Studying Today'),
          ),
        ],
      ),
    );
  }
}

// Animated Heart Icon
class _AnimatedHeartIcon extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onTap;
  final double size;

  const _AnimatedHeartIcon({
    required this.isLiked,
    required this.onTap,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(child: child, scale: animation);
        },
        child: Icon(
          isLiked ? Icons.favorite : LucideIcons.heart,
          key: ValueKey<bool>(isLiked),
          color: isLiked ? AppColors.error : colorScheme.primary,
          size: size,
        ),
      ),
    );
  }
}

// Feature Card
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      constraints: const BoxConstraints(maxWidth: 350),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.secondary.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: textTheme.titleLarge?.copyWith(fontSize: 20)),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
