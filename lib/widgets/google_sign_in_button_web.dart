import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart';

Widget buildGoogleSignInButton({
  required double width,
  required String languageCode,
}) {
  return SizedBox(
    width: width,
    height: 48,
    child: renderButton(
      configuration: GSIButtonConfiguration(
        type: GSIButtonType.standard,
        theme: GSIButtonTheme.outline,
        size: GSIButtonSize.large,
        text: GSIButtonText.continueWith,
        shape: GSIButtonShape.rectangular,
        logoAlignment: GSIButtonLogoAlignment.center,
        minimumWidth: width,
        locale: languageCode,
      ),
    ),
  );
}
