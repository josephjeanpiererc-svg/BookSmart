import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../widgets/pdf_web_view.dart';

class PdfReaderScreen extends StatelessWidget {
  const PdfReaderScreen({
    required this.title,
    required this.assetPath,
    super.key,
  });

  final String title;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final viewer = kIsWeb
        ? PdfWebView(assetUrl: Uri.base.resolve('assets/$assetPath').toString())
        : SfPdfViewer.asset(assetPath);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFFFF2DB),
        foregroundColor: const Color(0xFF1E2A39),
      ),
      body: viewer,
    );
  }
}
