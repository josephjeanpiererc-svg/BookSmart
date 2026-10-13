import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import 'login_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useFullScreen =
        shouldUseFullScreenLayout(defaultTargetPlatform) || kIsWeb;
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final frameWidth = useFullScreen
            ? availableWidth
            : (availableWidth - 32).clamp(280.0, 420.0);
        final frameHeight = useFullScreen
            ? availableHeight
            : (availableHeight - 32).clamp(500.0, 860.0);
        final contentScale = (frameWidth / 375).clamp(0.72, 1.2);
        final emblemSize = ((frameWidth * 0.62).clamp(
          180.0,
          290.0,
        )).clamp(0.0, availableHeight * 0.38);

        return Center(
          child: Container(
            width: frameWidth,
            height: frameHeight,
            padding: EdgeInsets.symmetric(
              horizontal: 22 * contentScale,
              vertical: 42 * contentScale,
            ),
            decoration: const BoxDecoration(color: Color(0xFFFFF2DB)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BookSmartEmblem(size: emblemSize),
                SizedBox(height: 28 * contentScale),
                LoadingLabel(scale: contentScale),
              ],
            ),
          ),
        );
      },
    );

    return Scaffold(body: useFullScreen ? body : SafeArea(child: body));
  }
}
