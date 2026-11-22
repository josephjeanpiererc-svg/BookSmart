import 'package:flutter/widgets.dart';

import 'google_sign_in_button_stub.dart'
    if (dart.library.js_interop) 'google_sign_in_button_web.dart'
    as platform;

Widget buildGoogleSignInButton({
  required double width,
  required String languageCode,
}) {
  return platform.buildGoogleSignInButton(
    width: width,
    languageCode: languageCode,
  );
}
