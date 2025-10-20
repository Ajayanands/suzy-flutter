import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Corrected import paths for your project structure
import 'package:suzy/src/pages/auth/register_screen.dart'; // Changed from SignupScreen
import 'package:suzy/src/pages/dashboard/dashboard_screen.dart'; // Assuming dashboard exists
import 'package:suzy/src/core/theme/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isLiked = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!mounted || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String identifier = _identifierController.text.trim();
      String password = _passwordController.text.trim();
      String? email;

      // Check if identifier looks like an email
      if (identifier.contains('@')) {
        email = identifier;
      } else {
        // Assume it's a username, query Firestore
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: identifier)
            .limit(1)
            .get();

        if (!mounted) return;

        if (userQuery.docs.isNotEmpty) {
          email = userQuery.docs.first.data()['email'] as String?;
        }
      }

      if (email == null) {
        // Throw an error if no email could be determined
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found for that username or email.',
        );
      }

      // Attempt sign-in with the determined email
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Navigate to Dashboard on successful login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (ctx) => const DashboardScreen()),
        (route) => false, // Remove all previous routes
      );
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please try again.';
      // Provide a clearer message for common login errors
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Incorrect username, email, or password.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('An unknown error occurred.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- UPDATED: Get all colors and styles from the theme ---
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          const double breakpoint = 900.0;
          bool isWideScreen = constraints.maxWidth > breakpoint;

          return isWideScreen
              ? Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildFormSection(
                        textTheme: textTheme,
                        colorScheme: colorScheme,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildIllustrationSection(
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildIllustrationSection(
                        colorScheme: colorScheme,
                        isMobile: !kIsWeb,
                      ),
                      _buildFormSection(
                        textTheme: textTheme,
                        colorScheme: colorScheme,
                        isDarkMode: isDarkMode,
                        isMobile: !kIsWeb,
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildFormSection({
    required TextTheme textTheme,
    required ColorScheme colorScheme,
    required bool isDarkMode,
    bool isMobile = false,
  }) {
    // Use secondary text color from your theme for muted text
    final Color mutedTextColor = isDarkMode
        ? AppColors.white.withAlpha(179) // 70% white for dark mode
        : AppColors.textSecondary_light; // Your specific light secondary color

    // Define the main text color explicitly
    final Color mainTextColor = isDarkMode
        ? AppColors.text_dark
        : AppColors.text_light;

    return Container(
      constraints: const BoxConstraints(maxWidth: 550),
      padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AnimatedHeartIcon(
                  isLiked: _isLiked,
                  onTap: _toggleLike,
                  size: 32,
                  defaultColor: colorScheme.primary,
                  likedColor: AppColors.error,
                ),
                const SizedBox(width: 12),
                Text(
                  "Suzy",
                  style: textTheme.headlineMedium?.copyWith(
                    color: mainTextColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 32),
            Text(
              "Welcome Back!",
              style:
                  (isMobile
                          ? textTheme.headlineMedium
                          : textTheme.headlineLarge)
                      ?.copyWith(color: mainTextColor),
            ),
            const SizedBox(height: 8),
            Text(
              "Login to continue your aesthetic study journey.",
              style: textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? mutedTextColor : mainTextColor,
              ),
            ),
            const SizedBox(height: 32),
            _buildTextFormField(
              controller: _identifierController,
              labelText: 'Email or Username',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email or username.';
                }
                return null;
              },
              textTheme: textTheme,
              colorScheme: colorScheme,
              mutedTextColor: mutedTextColor,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildTextFormField(
              controller: _passwordController,
              labelText: 'Password',
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: mutedTextColor,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your password.';
                }
                return null;
              },
              textTheme: textTheme,
              colorScheme: colorScheme,
              mutedTextColor: mutedTextColor,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDarkMode ? AppColors.black : AppColors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Login',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSecondary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? mutedTextColor : mainTextColor,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (ctx) => const RegisterScreen()),
                  ),
                  child: Text(
                    'Sign Up', // Changed from 'Login here'
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required FormFieldValidator<String> validator,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
    required Color mutedTextColor,
    required bool isDarkMode,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: textTheme.bodyLarge?.copyWith(
        color: isDarkMode ? AppColors.text_dark : AppColors.textSecondary_light,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: textTheme.bodyMedium?.copyWith(color: mutedTextColor),
        filled: true,
        fillColor: colorScheme.surface,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mutedTextColor.withAlpha(100)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mutedTextColor.withAlpha(100)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildIllustrationSection({
    required ColorScheme colorScheme,
    bool isMobile = false,
  }) {
    final double imageWidth = kIsWeb ? 480 : (isMobile ? 280 : 360);

    return Container(
      padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: imageWidth),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Image.asset(
                  'assets/images/SuzyLogin&Reg.png',
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(200),
                      shape: BoxShape.circle,
                    ),
                    child: _AnimatedHeartIcon(
                      isLiked: _isLiked,
                      onTap: _toggleLike,
                      size: 20,
                      defaultColor: AppColors.white,
                      likedColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable Heart Icon Widget (Keep this or import if you moved it)
class _AnimatedHeartIcon extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onTap;
  final double size;
  final Color defaultColor;
  final Color likedColor;

  const _AnimatedHeartIcon({
    required this.isLiked,
    required this.onTap,
    this.size = 32.0,
    required this.defaultColor,
    required this.likedColor,
  });

  @override
  Widget build(BuildContext context) {
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
          color: isLiked ? likedColor : defaultColor,
          size: size,
        ),
      ),
    );
  }
}
