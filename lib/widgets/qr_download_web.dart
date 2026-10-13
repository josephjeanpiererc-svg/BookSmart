import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'booksmart_widgets.dart';

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
      onPressed: () async {
        try {
          final link = web.HTMLAnchorElement()
            ..href = qrAssetUrl(assetPath)
            ..download = '${title}_QR.png'
            ..style.display = 'none';
          web.document.body?.append(link);
          link.click();
          link.remove();
        } catch (_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo descargar el QR.')),
          );
        }
      },
      tooltip: 'Descargar QR',
      icon: const Icon(Icons.download),
    );
  }
}
