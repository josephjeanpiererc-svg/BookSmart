import 'package:flutter/material.dart';

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
          const SnackBar(
            content: Text('Descarga disponible en la versión web.'),
          ),
        );
      },
      tooltip: 'Descargar QR',
      icon: const Icon(Icons.download),
    );
  }
}
