import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class PdfWebView extends StatelessWidget {
  PdfWebView({required this.assetUrl, super.key})
    : _viewType = 'pdf-view-${_nextViewId++}';

  final String assetUrl;
  final String _viewType;
  static int _nextViewId = 0;

  @override
  Widget build(BuildContext context) {
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = assetUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;
      return iframe;
    });

    return HtmlElementView(viewType: _viewType);
  }
}
