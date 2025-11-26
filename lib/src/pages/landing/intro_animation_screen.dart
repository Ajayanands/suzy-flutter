import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:suzy/src/pages/landing/landing_screen.dart';

class IntroAnimationScreen extends StatefulWidget {
  const IntroAnimationScreen({super.key});

  @override
  State<IntroAnimationScreen> createState() => _IntroAnimationScreenState();
}

class _IntroAnimationScreenState extends State<IntroAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Future<LottieComposition> _compositionFuture;

  @override
  void initState() {
    super.initState();
    // 1. Initialize the animation controller
    _controller = AnimationController(vsync: this);

    // 2. Start the loading process (with the 0.5s delay you requested)
    _compositionFuture = _loadComposition();
  }

  Future<LottieComposition> _loadComposition() async {
    // Wait for 0.5 seconds before showing/starting the animation
    await Future.delayed(const Duration(milliseconds: 500));

    // Load the animation file
    var asset = AssetLottie('assets/animations/Suzy_intro.json');
    return await asset.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LandingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Smooth fade transition to the Landing Page
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the theme's background color
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder<LottieComposition>(
        future: _compositionFuture,
        builder: (context, snapshot) {
          // --- 1. WAITING STATE (0.5s delay) ---
          if (snapshot.connectionState != ConnectionState.done) {
            // Show a clean empty screen while waiting
            return const SizedBox();
          }

          // --- 2. ERROR STATE (File missing) ---
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error:\n${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // --- 3. SUCCESS STATE (Play Animation) ---
          final composition = snapshot.data!;
          _controller.duration = composition.duration;

          // Play and then navigate
          _controller.forward().whenComplete(() => _navigateToHome());

          return Center(
            child: SizedBox(
              // RESPONSIVE LOGIC:
              // Force the animation container to match the exact screen size
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Lottie(
                composition: composition,
                controller: _controller,
                // 'contain' ensures the animation is NEVER cut off,
                // whether on a wide desktop or a tall phone.
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
