import 'package:flutter/material.dart';

import '../utils/app_localization.dart';

class QrDownloadButton extends StatelessWidget {
  const QrDownloadButton({
    required this.assetPath,
    required this.title,
    super.key,
  });

  final String assetPath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizedText(
                context,
                'Descarga disponible en la versión web.',
                'QR downloads are available on the web version.',
              ),
            ),
          ),
        );
      },
      tooltip: localizedText(context, 'Descargar QR', 'Download QR code'),
      icon: const Icon(Icons.download),
    );
  }
}
