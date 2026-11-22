import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/app_localization.dart';
import 'widgets/language_toggle_button.dart';
export 'screens/account_created_screen.dart';
export 'screens/email_verification_screen.dart';
export 'screens/home_screen.dart';
export 'screens/library_screen.dart';
export 'screens/loading_screen.dart';
export 'screens/login_screen.dart';
export 'screens/profile_screen.dart';
export 'screens/register_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFFF2DB),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('es');
  bool _isLanguageLoaded = false;

  @override
  void initState() {
    super.initState();
    _restoreLanguage();
  }

  Future<void> _restoreLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString('app_language');
    if (!mounted) {
      return;
    }
    final restoredLocale = switch (languageCode) {
      'es' => const Locale('es'),
      'en' => const Locale('en'),
      _ => _locale,
    };
    setState(() {
      _locale = restoredLocale;
      _isLanguageLoaded = true;
    });
  }

  Future<void> _toggleLanguage() async {
    final languageCode = _locale.languageCode == 'es' ? 'en' : 'es';
    setState(() => _locale = Locale(languageCode));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('app_language', languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookSmart',
      locale: _locale,
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      initialRoute: '/loading',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4C7599),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF2DB),
        fontFamily: 'Arial',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFE7E5E1),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF638DB1), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB3261E), width: 1),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      routes: {
        '/loading': (_) => const LoadingScreen(),
        '/login': (_) => const LoginScreen(),
      },
      home: const LoadingScreen(),
      builder: (context, child) => AppLanguageScope(
        locale: _locale,
        child: Stack(
          children: [
            ?child,
            Positioned(
              top: 8,
              right: 12,
              child: SafeArea(
                child: LanguageToggleButton(
                  locale: _locale,
                  onPressed: _isLanguageLoaded ? _toggleLanguage : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
