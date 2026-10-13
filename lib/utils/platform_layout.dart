import 'package:flutter/foundation.dart';

bool isPhoneLayout(double screenWidth) {
  return screenWidth > 0 && screenWidth < 500;
}

bool shouldUseFullScreenLayout(TargetPlatform platform) {
  return platform == TargetPlatform.android || kIsWeb;
}
