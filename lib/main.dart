import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Import Riverpod
import 'package:suzy/src/core/theme/theme.dart';
import 'package:suzy/src/core/theme/theme_provider.dart'; // 2. Import your new provider
import 'package:suzy/src/pages/landing/landing_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Wrap your app in a 'ProviderScope'
  runApp(const ProviderScope(child: SuzyApp()));
}

// 4. Change 'StatelessWidget' to 'ConsumerWidget'
class SuzyApp extends ConsumerWidget {
  const SuzyApp({super.key});

  // 5. Add 'WidgetRef ref' to the build method
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 6. Watch the provider to get the current theme
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Suzy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // 7. Use the themeMode from the provider
      themeMode: themeMode,
      home: const LandingScreen(),
    );
  }
}
