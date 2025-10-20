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

    String errorMessage = 'An unknown error occurred. Please try again.';

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'createdAt': Timestamp.now(),
          });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const LoginScreen()),
        );
      }
      return;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Email/password accounts are not enabled.';
      } else {
        errorMessage = 'Authentication error: ${e.message ?? e.code}';
      }
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException: ${e.code} - ${e.message}');
      errorMessage = 'Database error: ${e.message ?? e.code}';
    } catch (e, stackTrace) {
      debugPrint('Unexpected Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      errorMessage = 'An unexpected error occurred. Please try again later.';
    } finally {
      if (mounted) {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
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

  // -----------------------------------------------------------------
  // RESPONSIVE FIELD WIDTH HELPERS
  // -----------------------------------------------------------------
  double _fieldWidth(BuildContext context, {bool isMobile = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (isMobile || screenWidth < 600) ? double.infinity : 380.0;
  }

  Widget _responsiveField({
    required BuildContext context,
    required Widget child,
    bool isMobile = false,
  }) {
    final width = _fieldWidth(context, isMobile: isMobile);
    return width == double.infinity
        ? child
        : SizedBox(width: width, child: child);
  }

  // -----------------------------------------------------------------
  // CENTERING HELPERS (Desktop Only)
  // -----------------------------------------------------------------
  Widget _buildCenteredField({
    required bool shouldCenter,
    required Widget child,
  }) {
    return shouldCenter ? Center(child: child) : child;
  }

  Widget _buildHeader(
    TextTheme textTheme,
    ColorScheme colorScheme,
    Color mainTextColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
          style: textTheme.headlineMedium?.copyWith(color: mainTextColor),
        ),
      ],
    );
  }

  // -----------------------------------------------------------------
  // FORM SECTION (Centered on Desktop)
  // -----------------------------------------------------------------
  Widget _buildFormSection({
    required TextTheme textTheme,
    required ColorScheme colorScheme,
    required bool isDarkMode,
    bool isMobile = false,
  }) {
    final Color mutedTextColor = isDarkMode
        ? AppColors.white.withAlpha(179)
        : AppColors.textSecondary_light;

    final Color mainTextColor = isDarkMode
        ? AppColors.text_dark
        : AppColors.text_light;

    final bool shouldCenterFields = !isMobile;

    return Container(
      constraints: const BoxConstraints(maxWidth: 550),
      padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo + App Name
            _buildCenteredField(
              shouldCenter: shouldCenterFields,
              child: _buildHeader(textTheme, colorScheme, mainTextColor),
            ),
            SizedBox(height: isMobile ? 16 : 32),

            // Title
            _buildCenteredField(
              shouldCenter: shouldCenterFields,
              child: Text(
                "Create an Account",
                style:
                    (isMobile
                            ? textTheme.headlineMedium
                            : textTheme.headlineLarge)
                        ?.copyWith(color: mainTextColor),
                textAlign: shouldCenterFields
                    ? TextAlign.center
                    : TextAlign.start,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            _buildCenteredField(
              shouldCenter: shouldCenterFields,
              child: Text(
                "Join our community to start your aesthetic study journey.",
                style: textTheme.bodyLarge?.copyWith(
                  color: isDarkMode ? mutedTextColor : mainTextColor,
                ),
                textAlign: shouldCenterFields
                    ? TextAlign.center
                    : TextAlign.start,
              ),
            ),
            const SizedBox(height: 32),

            // Username Field
            _buildCenteredField(
              shouldCenter: shouldCenterFields,
              child: _responsiveField(
                context: context,
                isMobile: isMobile,
                child: _buildTextFormField(
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
                  isDarkMode: isDarkMode,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Email Field
            _buildCenteredField(
              shouldCenter: shouldCenterFields,
              child: _responsiveField(
                context: context,
                isMobile: isMobile,
                child: _buildTextFormField(
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
                  isDarkMode: isDarkMode,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Password Field
            _buildCenteredField(
              shouldCenter: shouldCenterFields,
              child: _responsiveField(
                context: context,
                isMobile: isMobile,
                child: _buildTextFormField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: mutedTextColor,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
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
                  isDarkMode: isDarkMode,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Password Field
            _buildCenteredField(
              shouldCenter: shouldCenterFields,
              child: _responsiveField(
                context: context,
                isMobile: isMobile,
                child: _buildTextFormField(
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
                  isDarkMode: isDarkMode,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Create Account Button
            _buildCenteredField(
              shouldCenter: shouldCenterFields,
              child: _responsiveField(
                context: context,
                isMobile: isMobile,
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
            ),
            const SizedBox(height: 24),

            // Login Link
            _buildCenteredField(
              shouldCenter: shouldCenterFields,
              child: Row(
                mainAxisSize: shouldCenterFields
                    ? MainAxisSize.min
                    : MainAxisSize.max,
                mainAxisAlignment: shouldCenterFields
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.center,
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
            ),
          ],
        ),
      ),
    );
  }

  // --- TextFormField Builder ---
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

  // --- Illustration Section ---
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

// Reusable Animated Heart Icon
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
