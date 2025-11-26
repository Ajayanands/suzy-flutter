import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:suzy/src/pages/landing/landing_screen.dart';

class IntroVideoScreen extends StatefulWidget {
  const IntroVideoScreen({super.key});

  @override
  State<IntroVideoScreen> createState() => _IntroVideoScreenState();
}

class _IntroVideoScreenState extends State<IntroVideoScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    // 1. Load the video asset
    // MAKE SURE you converted intro.mkv to intro.mp4
    _controller = VideoPlayerController.asset('assets/videos/suzy_intro.mp4');

    try {
      // 2. Initialize
      await _controller.initialize();

      // 3. CRITICAL: Mute to allow autoplay on all devices/browsers
      await _controller.setVolume(0.0);

      // 4. Ensure it plays once (like a splash screen)
      await _controller.setLooping(false);

      // 5. Update UI to show video instead of loader
      setState(() {
        _isInitialized = true;
      });

      // 6. Play!
      await _controller.play();

      // 7. Check every 200ms if video finished (Smoother than listener)
      Timer.periodic(const Duration(milliseconds: 200), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        // If video is initialized and has reached the end
        if (_controller.value.isInitialized &&
            _controller.value.position >= _controller.value.duration) {
          timer.cancel();
          _navigateToHome();
        }
      });
    } catch (e) {
      debugPrint("Error initializing intro video: $e");
      // If video is broken, skip to home immediately so user isn't stuck
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    // Smooth fade to the Landing Page
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LandingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(
          milliseconds: 1000,
        ), // Slow, cinematic fade
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use black background for cinematic feel
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: _isInitialized
            ? FittedBox(
                // COVER: Scales video to fill screen, cropping edges if needed.
                // This makes it look like a native animation background.
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            : const Center(
                // Show a loading spinner while video prepares
                // (Prevents the "broken black screen" look)
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
      ),
    );
  }
}
