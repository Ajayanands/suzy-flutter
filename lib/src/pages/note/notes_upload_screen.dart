import 'package:flutter/material.dart';

// This is just a placeholder screen.
class UploadNotesScreen extends StatelessWidget {
  const UploadNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use transparent background so it blends with the dashboard's background
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          'Upload Notes Screen - Placeholder',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
