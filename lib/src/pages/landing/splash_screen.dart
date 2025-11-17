import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:suzy/src/pages/landing/landing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to LandingScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LandingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/animations/technology.json',
          fit: BoxFit.contain,
          repeat: false, // Play once
          width: double.infinity,
          height: double.infinity,
          onLoaded: (composition) {
            // Animation is ~3 seconds (180 frames at 60fps)
          },
        ),
      ),
    );
  }
}
