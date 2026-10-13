import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import 'catalog_screen.dart';
import 'library_screen.dart';

class FreeQrScreen extends QrScreen {
  const FreeQrScreen({super.key, super.displayName}) : super(paidPlan: false);
}

class PaidQrScreen extends QrScreen {
  const PaidQrScreen({super.key, super.displayName}) : super(paidPlan: true);
}

class QrScreen extends StatelessWidget {
  const QrScreen({
    super.key,
    this.displayName = 'Usuario',
    required this.paidPlan,
  });

  final String displayName;
  final bool paidPlan;

  @override
  Widget build(BuildContext context) {
    final useFullScreen =
        shouldUseFullScreenLayout(defaultTargetPlatform) || kIsWeb;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: const ScreenCloseButton(),
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
                              'Puedes escanear tu QR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 19 * scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 12 * scale),
                            Semantics(
                              label: 'Espacio reservado para la cámara',
                              child: _QrCameraBox(
                                width: cameraWidth,
                                height: cameraWidth * 1.12,
                                scale: scale,
                                displayName: displayName,
                                onBookRecognized: (title) {
                                  final isOwned =
                                      CatalogScreen.ownedBookTitlesFor(
                                        displayName,
                                      ).contains(title);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => isOwned
                                          ? LibraryScreen(
                                              displayName: displayName,
                                              initialBookTitle: title,
                                            )
                                          : CatalogScreen(
                                              displayName: displayName,
                                              paidPlan: paidPlan,
                                              initialBookTitle: title,
                                            ),
                                    ),
                                  );
                                },
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
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QrCameraBox extends StatefulWidget {
  const _QrCameraBox({
    required this.width,
    required this.height,
    required this.scale,
    required this.displayName,
    required this.onBookRecognized,
  });

  final double width;
  final double height;
  final double scale;
  final String displayName;
  final ValueChanged<String> onBookRecognized;

  @override
  State<_QrCameraBox> createState() => _QrCameraBoxState();
}

class _QrCameraBoxState extends State<_QrCameraBox> {
  // El visor se incorpora primero al árbol de widgets y la cámara se inicia
  // después. Iniciarla antes puede dejar una vista negra, especialmente en web.
  final _controller = MobileScannerController(autoStart: false);
  bool _cameraActive = false;
  bool _hasDetectedCode = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _activateCamera() async {
    if (_hasDetectedCode) return;
    setState(() => _cameraActive = true);

    // Espera a que MobileScanner esté asociado al controlador antes de abrir
    // la cámara.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    try {
      await _controller.start();
    } catch (_) {
      if (!mounted) return;
      setState(() => _cameraActive = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permite el acceso a la cámara para escanear el QR.'),
        ),
      );
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasDetectedCode || capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    final title = CatalogScreen.titleForQrCode(value);
    if (!mounted) return;
    if (title == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR no reconocido. Usa un QR de un libro.'),
        ),
      );
      return;
    }

    _hasDetectedCode = true;
    final userKey = widget.displayName;
    CatalogScreen.ownedBookTitlesFor(userKey).add(title);
    if (!CatalogScreen.readingBookTitlesFor(userKey).contains(title) &&
        !CatalogScreen.pendingBookTitlesFor(userKey).contains(title) &&
        !CatalogScreen.completedBookTitlesFor(userKey).contains(title)) {
      CatalogScreen.setBookStatus(title, BookReadingStatus.reading, userKey);
    }
    setState(() => _cameraActive = false);
    await _controller.stop();
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
                controller: _controller,
                onDetect: _onDetect,
                errorBuilder: (context, error) => Material(
                  color: const Color(0xFFF5D267),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(18 * widget.scale),
                      child: Text(
                        'No se pudo activar la cámara.\nPermite el acceso e inténtalo de nuevo.',
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
                        'Activar cámara',
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
