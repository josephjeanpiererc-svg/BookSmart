import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../utils/app_localization.dart';
import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import 'catalog_screen.dart';
import 'library_screen.dart';

class FreeQrScreen extends QrScreen {
  const FreeQrScreen({super.key, super.displayName, super.userId})
    : super(paidPlan: false);
}

class PaidQrScreen extends QrScreen {
  const PaidQrScreen({super.key, super.displayName, super.userId})
    : super(paidPlan: true);
}

class QrScreen extends StatefulWidget {
  const QrScreen({
    super.key,
    this.displayName = 'Usuario',
    this.userId,
    required this.paidPlan,
  });

  final String displayName;
  final String? userId;
  final bool paidPlan;

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final _controller = MobileScannerController(autoStart: false);
  bool _isClosing = false;

  String get _accountId => widget.userId ?? widget.displayName;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  Future<void> _closeScanner() async {
    if (_isClosing) return;
    setState(() => _isClosing = true);
    await WidgetsBinding.instance.endOfFrame;
    try {
      await _controller.stop();
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _openBook(String title) async {
    final isOwned = CatalogScreen.ownedBookTitlesFor(_accountId)
        .contains(title);
    setState(() => _isClosing = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => isOwned
            ? LibraryScreen(userId: _accountId, initialBookTitle: title)
            : CatalogScreen(
                displayName: widget.displayName,
                userId: _accountId,
                paidPlan: widget.paidPlan,
                initialBookTitle: title,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final useFullScreen =
        shouldUseFullScreenLayout(defaultTargetPlatform) || kIsWeb;

    return PopScope<void>(
      canPop: _isClosing,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_closeScanner());
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: ScreenCloseButton(onPressed: _closeScanner),
        floatingActionButtonLocation: screenCloseButtonLocation,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final frameWidth = useFullScreen
                ? width
                : (width - 32).clamp(280.0, 440.0);
            final scale = useFullScreen
                ? (width / 430).clamp(0.72, 1.0)
                : (frameWidth / 375).clamp(0.68, 1.1);
            final contentWidth = (width - 40 * scale).clamp(220.0, 360.0);
            final logoSize = (contentWidth * 0.68).clamp(150.0, 230.0);
            final cameraWidth = (contentWidth * 0.82).clamp(190.0, 290.0);

            return Center(
              child: Container(
                width: frameWidth,
                height: useFullScreen
                    ? constraints.maxHeight
                    : constraints.maxHeight - 24,
                decoration: BoxDecoration(color: const Color(0xFFFFF2DB)),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        20 * scale,
                        28 * scale,
                        20 * scale,
                        88 * scale,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/principal_logo.jpeg',
                                width: logoSize,
                                height: logoSize,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 20 * scale),
                              Text(
                                localizedText(
                                  context,
                                  'Puedes escanear tu QR',
                                  'You can scan your QR code',
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 19 * scale,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 12 * scale),
                              Semantics(
                                label: localizedText(
                                  context,
                                  'Espacio reservado para la cámara',
                                  'Camera preview',
                                ),
                                child: _QrCameraBox(
                                  controller: _controller,
                                  width: cameraWidth,
                                  height: cameraWidth * 1.12,
                                  scale: scale,
                                  userId: _accountId,
                                  onBookRecognized: _openBook,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8 * scale,
                      bottom: 8 * scale,
                      child: _QrFloatingButton(
                        scale: scale,
                        onPressed: _closeScanner,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QrCameraBox extends StatefulWidget {
  const _QrCameraBox({
    required this.controller,
    required this.width,
    required this.height,
    required this.scale,
    required this.userId,
    required this.onBookRecognized,
  });

  final MobileScannerController controller;
  final double width;
  final double height;
  final double scale;
  final String userId;
  final ValueChanged<String> onBookRecognized;

  @override
  State<_QrCameraBox> createState() => _QrCameraBoxState();
}

class _QrCameraBoxState extends State<_QrCameraBox> {
  bool _cameraActive = false;
  bool _hasDetectedCode = false;
  bool _isHandlingCode = false;

  Future<void> _activateCamera() async {
    if (_hasDetectedCode) return;
    setState(() => _cameraActive = true);

    // Espera a que MobileScanner esté asociado al controlador antes de abrir
    // la cámara.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    try {
      await widget.controller.start();
      if (!mounted) {
        await widget.controller.stop();
        return;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _cameraActive = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizedText(
              context,
              'Permite el acceso a la cámara para escanear el QR.',
              'Allow camera access to scan the QR code.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasDetectedCode || _isHandlingCode || capture.barcodes.isEmpty) {
      return;
    }
    final value = capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    _isHandlingCode = true;
    await widget.controller.stop();
    if (!mounted) return;
    setState(() => _cameraActive = false);

    final title = CatalogScreen.titleForQrCode(value);
    if (title == null) {
      _isHandlingCode = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizedText(
              context,
              'QR no reconocido. Usa un QR de un libro.',
              'QR code not recognized. Use a book QR code.',
            ),
          ),
        ),
      );
      return;
    }

    _hasDetectedCode = true;
    final userKey = widget.userId;
    CatalogScreen.ownedBookTitlesFor(userKey).add(title);
    if (!CatalogScreen.readingBookTitlesFor(userKey).contains(title) &&
        !CatalogScreen.pendingBookTitlesFor(userKey).contains(title) &&
        !CatalogScreen.completedBookTitlesFor(userKey).contains(title)) {
      CatalogScreen.setBookStatus(title, BookReadingStatus.reading, userKey);
    }
    await CatalogScreen.persistUserLibrary(userKey);
    if (!mounted) return;
    widget.onBookRecognized(title);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(26 * widget.scale);
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_cameraActive)
              MobileScanner(
                controller: widget.controller,
                onDetect: _onDetect,
                errorBuilder: (context, error) => Material(
                  color: const Color(0xFFF5D267),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(18 * widget.scale),
                      child: Text(
                        localizedText(
                          context,
                          'No se pudo activar la cámara.\nPermite el acceso e inténtalo de nuevo.',
                          'Could not start the camera.\nAllow access and try again.',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15 * widget.scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (!_cameraActive)
              Material(
                color: const Color(0xFFF5D267),
                child: InkWell(
                  onTap: _activateCamera,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: 54 * widget.scale,
                        color: const Color(0xFF28639B),
                      ),
                      SizedBox(height: 10 * widget.scale),
                      Text(
                        localizedText(
                          context,
                          'Activar cámara',
                          'Start camera',
                        ),
                        style: TextStyle(
                          fontSize: 16 * widget.scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QrFloatingButton extends StatelessWidget {
  const _QrFloatingButton({required this.scale, required this.onPressed});

  final double scale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = 62 * scale;
    return SizedBox(
      width: size + 12 * scale,
      height: size + 12 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 6 * scale,
            bottom: 0,
            child: Material(
              color: Colors.black,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                onTap: onPressed,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Icon(
                    Icons.qr_code_2,
                    color: Colors.white,
                    size: 48 * scale,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -1 * scale,
            top: -1 * scale,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onPressed,
                customBorder: const CircleBorder(),
                child: Icon(Icons.close, size: 22 * scale, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
