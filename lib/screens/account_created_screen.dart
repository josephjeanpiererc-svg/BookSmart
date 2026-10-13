import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import 'login_screen.dart';

class AccountCreatedScreen extends StatefulWidget {
  const AccountCreatedScreen({super.key});

  @override
  State<AccountCreatedScreen> createState() => _AccountCreatedScreenState();
}

class _AccountCreatedScreenState extends State<AccountCreatedScreen> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useFullScreen =
        shouldUseFullScreenLayout(defaultTargetPlatform) || kIsWeb;
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final frameWidth = useFullScreen
            ? width
            : (width - 32).clamp(280.0, 440.0);
        final scale = useFullScreen
            ? (width / 600).clamp(0.82, 1.0)
            : (frameWidth / 375).clamp(0.68, 1.15);
        final logoSize = useFullScreen
            ? (height * 0.22).clamp(140.0, 190.0)
            : (frameWidth * 0.44).clamp(140.0, 205.0);

        return Center(
          child: Container(
            width: frameWidth,
            height: useFullScreen ? height : (height - 24).clamp(560.0, 900.0),
            padding: EdgeInsets.symmetric(
              horizontal: useFullScreen ? 24 : 22 * scale,
              vertical: 30 * scale,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2DB),
              border: useFullScreen
                  ? null
                  : Border.all(
                      color: const Color(0xFF39688F),
                      width: 9 * scale,
                    ),
              borderRadius: useFullScreen
                  ? null
                  : BorderRadius.circular(28 * scale),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BookSmartEmblem(size: logoSize),
                  SizedBox(height: 48 * scale),
                  Text(
                    'Cuenta creada\ncon éxito',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28 * scale,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 28 * scale),
                  Container(
                    width: 160 * scale,
                    height: 160 * scale,
                    decoration: const BoxDecoration(
                      color: Color(0xFF63F53D),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: const Color(0xFFFFF2DB),
                      size: 120 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return Scaffold(
      floatingActionButton: const ScreenCloseButton(),
      floatingActionButtonLocation: screenCloseButtonLocation,
      body: useFullScreen ? body : SafeArea(child: body),
    );
  }
}
