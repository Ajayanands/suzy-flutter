// lib/src/pages/note/notes_upload_screen.dart

import 'dart:async';
import 'dart:io' show File;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

// Only use AppColors for specific brand colors; everything else from Theme.
import 'package:suzy/src/core/theme/colors.dart';

enum UploadState { idle, uploading, success }

class UploadNotesScreen extends StatefulWidget {
  const UploadNotesScreen({super.key});

  @override
  State<UploadNotesScreen> createState() => _UploadNotesScreenState();
}

class _UploadNotesScreenState extends State<UploadNotesScreen>
    with TickerProviderStateMixin {
  UploadState _uploadState = UploadState.idle;

  PlatformFile? _selectedFile;
  UploadTask? _uploadTask;
  double _uploadProgress = 0.0;

  // Small playful animations
  late final AnimationController _fileBounceController;
  late final AnimationController _gaugePulseController;
  late final Animation<double> _fileBounceAnim;
  late final Animation<double> _gaugePulseAnim;

  @override
  void initState() {
    super.initState();

    _fileBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _gaugePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _gaugePulseAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _gaugePulseController, curve: Curves.elasticOut),
    );

    _fileBounceAnim = Tween<double>(begin: 0.0, end: 6.0).animate(
      CurvedAnimation(parent: _fileBounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fileBounceController.dispose();
    _gaugePulseController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  //                             FILE PICKER
  // ---------------------------------------------------------------------------

  Future<void> _selectFile() async {
    if (_uploadState == UploadState.uploading) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg', 'jpeg'],
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty || !mounted) return;

      setState(() {
        _selectedFile = result.files.first;
      });

      await _startUpload();
    } catch (e) {
      _showErrorSnackBar('Could not pick file: $e');
    }
  }

  // ---------------------------------------------------------------------------
  //                             UPLOAD LOGIC
  // ---------------------------------------------------------------------------

  Future<void> _startUpload() async {
    if (_selectedFile == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar('You must be logged in to upload.');
      return;
    }

    try {
      Uint8List? fileBytes;
      String? filePath;

      if (kIsWeb) {
        fileBytes = _selectedFile!.bytes;
        if (fileBytes == null) {
          _showErrorSnackBar('Failed to read file on web.');
          return;
        }
      } else {
        filePath = _selectedFile!.path;
        if (filePath == null || !await File(filePath).exists()) {
          _showErrorSnackBar('File not found on device.');
          return;
        }
      }

      final fileName = _selectedFile!.name;
      final extension = _selectedFile!.extension ?? 'unknown';

      final storagePath =
          'notes/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      setState(() {
        _uploadState = UploadState.uploading;
        _uploadProgress = 0.0;
      });

      final ref = FirebaseStorage.instance.ref(storagePath);

      _uploadTask = kIsWeb
          ? ref.putData(fileBytes!)
          : ref.putFile(File(filePath!));

      _uploadTask!.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          if (!mounted) return;
          if (snapshot.totalBytes == 0) return;

          setState(() {
            _uploadProgress =
                snapshot.bytesTransferred /
                snapshot.totalBytes.clamp(1, 1 << 31);
          });

          if (_uploadProgress >= 1.0) {
            _gaugePulseController
              ..reset()
              ..forward();
          }
        },
        onError: (e) {
          if (!mounted) return;
          _handleUploadError('Upload failed: $e');
        },
      );

      final completedSnapshot = await _uploadTask!.whenComplete(() {});
      final downloadUrl = await completedSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('notes').add({
        'userId': user.uid,
        'fileName': fileName,
        'downloadUrl': downloadUrl,
        'fileType': extension,
        'size': _selectedFile!.size,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      setState(() {
        _uploadState = UploadState.success;
      });

      _showSuccessSnackBar('"$fileName" uploaded successfully!');
    } on FirebaseException catch (e) {
      _handleUploadError(e.message ?? 'Firebase upload error');
    } catch (e) {
      _handleUploadError('Unexpected error: $e');
    }
  }

  void _handleUploadError(String message) {
    _showErrorSnackBar(message);

    if (!mounted) return;

    setState(() {
      _uploadState = UploadState.idle;
      _uploadProgress = 0.0;
      _uploadTask = null;
    });
  }

  void _cancelUpload() {
    _uploadTask?.cancel();
    _uploadTask = null;

    if (!mounted) return;

    setState(() {
      _uploadState = UploadState.idle;
      _uploadProgress = 0.0;
      _selectedFile = null;
    });

    _showErrorSnackBar('Upload cancelled');
  }

  void _resetToIdle() {
    if (!mounted) return;
    setState(() {
      _uploadState = UploadState.idle;
      _uploadProgress = 0.0;
      _selectedFile = null;
      _uploadTask = null;
    });
  }

  // ---------------------------------------------------------------------------
  //                             UI HELPERS
  // ---------------------------------------------------------------------------

  void _showErrorSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String msg) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  IconData _fileIcon(String? ext) {
    switch ((ext ?? '').toLowerCase()) {
      case 'pdf':
        return LucideIcons.file;
      case 'doc':
      case 'docx':
        return LucideIcons.fileText;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return LucideIcons.image;
      default:
        return LucideIcons.file;
    }
  }

  // ---------------------------------------------------------------------------
  //                                  BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark
        ? AppColors.text_dark
        : AppColors.text_light; // for header

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Note',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Watch your file travel from cozy desk to cloud!',
                style: textTheme.bodyLarge?.copyWith(color: textColor),
              ),
              const SizedBox(height: 32),

              // Main animated content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final scale = Tween<double>(
                      begin: 0.95,
                      end: 1.0,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: scale, child: child),
                    );
                  },
                  child: _buildStateBody(isDark, theme),
                ),
              ),

              const SizedBox(height: 16),

              // Small status line
              Center(
                child: Text(
                  _uploadState == UploadState.idle
                      ? 'Tap the glowing file on the desk to begin your journey.'
                      : _uploadState == UploadState.uploading
                      ? 'Sending your note to the study cloud...'
                      : 'Upload done — your note is now in the cloud!',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateBody(bool isDark, ThemeData theme) {
    switch (_uploadState) {
      case UploadState.idle:
        return _buildIdleScene(isDark, theme);
      case UploadState.uploading:
        return _buildUploadingScene(theme);
      case UploadState.success:
        return _buildSuccessScene(theme);
    }
  }

  // ---------------------------------------------------------------------------
  //                               IDLE SCENE
  // ---------------------------------------------------------------------------

  Widget _buildIdleScene(bool isDark, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox.expand(
      key: const ValueKey('idle_scene'),
      child: Stack(
        children: [
          // Desk + computer
          Positioned.fill(
            child: ComputerDeskScene(
              primaryColor: colorScheme.primary,
              secondaryColor: colorScheme.secondary,
              surfaceColor: colorScheme.surface,
              scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
              isDark: isDark,
            ),
          ),

          // Floating file icon on desk (tap target)
          Positioned(
            bottom: 120,
            left: 80,
            child: GestureDetector(
              onTap: _selectFile,
              child: AnimatedBuilder(
                animation: _fileBounceAnim,
                builder: (context, child) {
                  final bounce = _fileBounceAnim.value;
                  return Transform.translate(
                    offset: Offset(0, -bounce),
                    child: Transform.rotate(
                      angle: math.sin(bounce / 6) * 0.05,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _fileIcon(_selectedFile?.extension),
                        size: 40,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap to upload',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Subtle cloud hint above monitor
          Positioned(
            top: 40,
            right: 70,
            child: Row(
              children: [
                Icon(
                  LucideIcons.cloud,
                  size: 26,
                  color: colorScheme.primary.withOpacity(0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  'Destination: Cloud',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //                             UPLOADING SCENE
  // ---------------------------------------------------------------------------

  Widget _buildUploadingScene(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final fileName = _selectedFile?.name ?? 'Your note';
    final fileExt = _selectedFile?.extension;

    return SizedBox.expand(
      key: const ValueKey('uploading_scene'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _gaugePulseAnim,
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background soft halo
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colorScheme.primary.withOpacity(0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Gauge
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: _uploadProgress.clamp(0.0, 1.0),
                      strokeWidth: 9,
                      backgroundColor: colorScheme.surface.withOpacity(0.4),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Content inside
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_uploadProgress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        _fileIcon(fileExt),
                        size: 28,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Uploading "$fileName"',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Don’t close this screen until the upload completes.',
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _cancelUpload,
            icon: Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
            label: Text(
              'Cancel upload',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //                             SUCCESS SCENE
  // ---------------------------------------------------------------------------

  Widget _buildSuccessScene(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox.expand(
      key: const ValueKey('success_scene'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/confetti.json',
            repeat: false,
            width: 260,
            height: 260,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Icon(
            Icons.check_circle_rounded,
            size: 36,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Upload Complete!',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Your note has safely reached the cloud. You can now access it from anywhere.',
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.75),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _resetToIdle,
            icon: const Icon(Icons.upload_file_rounded, size: 18),
            label: const Text('Upload another note'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//                         CUSTOM PAINTER – Desk + Computer
// ---------------------------------------------------------------------------

class ComputerDeskScene extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;
  final Color scaffoldBackgroundColor;
  final bool isDark;

  const ComputerDeskScene({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.scaffoldBackgroundColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ComputerDeskPainter(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        surfaceColor: surfaceColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        isDark: isDark,
      ),
      size: Size.infinite,
    );
  }
}

class ComputerDeskPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;
  final Color scaffoldBackgroundColor;
  final bool isDark;

  ComputerDeskPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.scaffoldBackgroundColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Background gradient hint
    final bgRect = Offset.zero & size;
    final bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        scaffoldBackgroundColor,
        scaffoldBackgroundColor.withOpacity(
          isDark ? 0.98 : 0.96,
        ), // subtle gradient
      ],
    );
    paint.shader = bgGradient.createShader(bgRect);
    canvas.drawRect(bgRect, paint);
    paint.shader = null;

    // Desk
    final deskHeight = 180.0;
    final deskRect = Rect.fromLTWH(
      0,
      size.height - deskHeight,
      size.width,
      deskHeight,
    );

    paint
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(deskRect, const Radius.circular(24)),
      paint,
    );

    // Desk top highlight
    final deskHighlight = Rect.fromLTWH(
      0,
      size.height - deskHeight,
      size.width,
      14,
    );
    final deskGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(isDark ? 0.02 : 0.12),
        Colors.transparent,
      ],
    );
    paint.shader = deskGradient.createShader(deskHighlight);
    canvas.drawRect(deskHighlight, paint);
    paint.shader = null;

    // Monitor
    final monWidth = 260.0;
    final monHeight = 170.0;
    final monX = (size.width - monWidth) / 2;
    final monY = size.height - deskHeight - monHeight - 24;

    final screenRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(monX, monY, monWidth, monHeight),
      const Radius.circular(18),
    );

    // Monitor body
    paint.color = isDark ? const Color(0xFF151515) : surfaceColor;
    canvas.drawRRect(screenRRect, paint);

    // Monitor border
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = secondaryColor.withOpacity(0.9);
    canvas.drawRRect(screenRRect, paint);

    // Monitor glow
    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawRRect(screenRRect, glowPaint);

    paint
      ..style = PaintingStyle.fill
      ..maskFilter = null;

    // Screen content: simple "code lines"
    final codeLinePaint = Paint()
      ..color = primaryColor.withOpacity(0.45)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    final innerPadding = 18.0;
    final lineStartX = monX + innerPadding;
    final lineEndX = monX + monWidth - innerPadding;

    for (int i = 0; i < 5; i++) {
      final dy = monY + innerPadding + i * 18;
      final pct = 0.4 + (i * 0.1);
      canvas.drawLine(
        Offset(lineStartX, dy),
        Offset(lineStartX + (lineEndX - lineStartX) * pct.clamp(0.0, 1.0), dy),
        codeLinePaint,
      );
    }

    // Monitor stand
    final standWidth = 60.0;
    final standHeight = 18.0;
    final standRect = Rect.fromCenter(
      center: Offset(monX + monWidth / 2, monY + monHeight + standHeight / 2),
      width: standWidth,
      height: standHeight,
    );
    paint.color = primaryColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(standRect, const Radius.circular(6)),
      paint,
    );

    // Stand base
    final baseWidth = 110.0;
    final baseHeight = 12.0;
    final baseRect = Rect.fromCenter(
      center: Offset(standRect.center.dx, standRect.bottom + baseHeight / 1.5),
      width: baseWidth,
      height: baseHeight,
    );
    paint.color = primaryColor.withOpacity(0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(8)),
      paint,
    );

    // Coffee mug on desk
    final mugWidth = 30.0;
    final mugHeight = 40.0;
    final mugRect = Rect.fromLTWH(
      monX - 80,
      size.height - deskHeight + 40,
      mugWidth,
      mugHeight,
    );

    paint.color = secondaryColor.withOpacity(0.95);
    canvas.drawRRect(
      RRect.fromRectAndRadius(mugRect, const Radius.circular(8)),
      paint,
    );

    // Mug handle
    final handleRect = Rect.fromLTWH(
      mugRect.right - 6,
      mugRect.top + 10,
      10,
      16,
    );
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(handleRect, const Radius.circular(8)),
      paint,
    );
    paint.style = PaintingStyle.fill;

    // Steam lines
    final steamPaint = Paint()
      ..color = primaryColor.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      final sx = mugRect.left + 6 + i * 6;
      canvas.drawLine(
        Offset(sx, mugRect.top - 4),
        Offset(sx, mugRect.top - 14),
        steamPaint,
      );
    }

    // Notebook on desk
    final notebookRect = Rect.fromLTWH(
      monX + monWidth + 20,
      size.height - deskHeight + 56,
      90,
      52,
    );
    paint.color = primaryColor.withOpacity(0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(notebookRect, const Radius.circular(10)),
      paint,
    );

    // Notebook spine
    paint.color = primaryColor.withOpacity(0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          notebookRect.left,
          notebookRect.top,
          6,
          notebookRect.height,
        ),
        const Radius.circular(6),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ComputerDeskPainter oldDelegate) {
    return primaryColor != oldDelegate.primaryColor ||
        secondaryColor != oldDelegate.secondaryColor ||
        surfaceColor != oldDelegate.surfaceColor ||
        scaffoldBackgroundColor != oldDelegate.scaffoldBackgroundColor ||
        isDark != oldDelegate.isDark;
  }
}
