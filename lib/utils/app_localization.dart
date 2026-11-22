import 'package:flutter/widgets.dart';

class AppLanguageScope extends InheritedWidget {
  const AppLanguageScope({
    required this.locale,
    required super.child,
    super.key,
  });

  final Locale locale;

  static Locale? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppLanguageScope>()
        ?.locale;
  }

  @override
  bool updateShouldNotify(AppLanguageScope oldWidget) {
    return locale != oldWidget.locale;
  }
}

String localizedText(BuildContext context, String spanish, String english) {
  final locale = AppLanguageScope.maybeOf(context);
  return locale?.languageCode == 'en' ? english : spanish;
}
