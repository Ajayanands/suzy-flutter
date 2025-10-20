import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Corrected import paths for your project structure
import 'package:suzy/src/pages/auth/login_screen.dart';
import 'package:suzy/src/core/theme/colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isLiked = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!mounted || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // --- Default error message ---
    String errorMessage = 'An unknown error occurred. Please try again.';

    try {
      // --- Step 1: Create User ---
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // --- Step 2: Save User Data to Firestore ---
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            // Optional: Add createdAt timestamp
            'createdAt': Timestamp.now(),
          });

      // --- Step 3: Navigate on Success ---
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const LoginScreen()),
        );
      }
      // Explicitly return here on success before finally block
      return;
    } on FirebaseAuthException catch (e) {
      // --- Handle Specific Firebase Auth Errors ---
      debugPrint(
        'FirebaseAuthException: ${e.code} - ${e.message}',
      ); // Log the specific error code
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage =
            'Email/password accounts are not enabled.'; // Check Firebase Console
      } else {
        errorMessage =
            'Authentication error: ${e.message ?? e.code}'; // Show specific Auth error message
      }
    } on FirebaseException catch (e) {
      // --- Handle Potential Firestore or other Firebase Errors ---
      debugPrint(
        'FirebaseException: ${e.code} - ${e.message}',
      ); // Log the specific error code
      errorMessage =
          'Database error: ${e.message ?? e.code}'; // Show specific Firebase error message
      // You might want specific messages for Firestore permission errors if needed
    } catch (e, stackTrace) {
      // --- Catch ANY other unexpected errors ---
      debugPrint('Unexpected Error: $e');
      debugPrint('Stack Trace: $stackTrace'); // Log stack trace for debugging
      errorMessage = 'An unexpected error occurred. Please try again later.';
    } finally {
      // --- This always runs, whether try succeeded or failed ---
      if (mounted) {
        // Only show Snackbar if there was an error message set (i.e., not successful signup)
        // Check if errorMessage is still the default (or changed)
        // A better way: Check if signup was successful before showing error.
        // We handle navigation on success inside try, so if we reach finally
        // without navigating, it means an error occurred.
        // Check if we are still on this screen
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }

        // Always turn off loading indicator
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
    // Muted text color logic remains the same
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
              "Create an Account",
              style:
                  (isMobile
                          ? textTheme.headlineMedium
                          : textTheme.headlineLarge)
                      ?.copyWith(color: mainTextColor),
            ),
            const SizedBox(height: 8),
            Text(
              "Join our community to start your aesthetic study journey.",
              style: textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? mutedTextColor : mainTextColor,
              ),
            ),
            const SizedBox(height: 32),
            _buildTextFormField(
              controller: _usernameController,
              labelText: 'Username',
              validator: (value) {
                if (value == null || value.trim().length < 3) {
                  return 'Username must be at least 3 characters.';
                }
                return null;
              },
              textTheme: textTheme,
              colorScheme: colorScheme,
              mutedTextColor: mutedTextColor,
              isDarkMode: isDarkMode, // Pass down theme mode
            ),
            const SizedBox(height: 24),
            _buildTextFormField(
              controller: _emailController,
              labelText: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || !value.contains('@')) {
                  return 'Please enter a valid email.';
                }
                return null;
              },
              textTheme: textTheme,
              colorScheme: colorScheme,
              mutedTextColor: mutedTextColor,
              isDarkMode: isDarkMode, // Pass down theme mode
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
                if (value == null || value.trim().length < 6) {
                  return 'Password must be at least 6 characters.';
                }
                return null;
              },
              textTheme: textTheme,
              colorScheme: colorScheme,
              mutedTextColor: mutedTextColor,
              isDarkMode: isDarkMode, // Pass down theme mode
            ),
            const SizedBox(height: 24),
            _buildTextFormField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              obscureText: true,
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match.';
                }
                return null;
              },
              textTheme: textTheme,
              colorScheme: colorScheme,
              mutedTextColor: mutedTextColor,
              isDarkMode: isDarkMode, // Pass down theme mode
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signup,
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
                        'Create Account',
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
                  "Already have an account?",
                  style: textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? mutedTextColor : mainTextColor,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                  ),
                  child: Text(
                    'Login here',
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

  // --- Updated _buildTextFormField ---
  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required FormFieldValidator<String> validator,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
    required Color mutedTextColor,
    required bool isDarkMode, // Added this
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      // --- THIS IS THE FIX ---
      // Use a conditional color for the typed text
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

// Reusable Heart Icon Widget
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
