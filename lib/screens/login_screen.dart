import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/booksmart_database.dart';
import '../utils/app_localization.dart';
import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import '../widgets/google_sign_in_button.dart';
import 'catalog_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';

const _googleWebClientId =
    '124623828564-a954odqh2ic523mbj9olihsh302d2ghf.apps.googleusercontent.com';
final _androidAppDownloadUri = Uri.parse(
  'https://josephjeanpiererc-svg.github.io/BookSmart/downloads/booksmart.apk',
);
Future<void>? _googleSignInInitialization;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSigningInWithGoogle = false;
  bool _googleSignInReady = false;
  StreamSubscription<GoogleSignInAuthenticationEvent>?
  _googleSignInSubscription;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) unawaited(_prepareGoogleSignIn());
  }

  bool get _supportsGoogleSignIn =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.android;

  @override
  void dispose() {
    _googleSignInSubscription?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    if (kIsWeb) {
      final user = await BooksmartDatabase.instance.authenticatePassword(
        username: username,
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (user == null) {
        _showMessage(
          localizedText(
            context,
            'Usuario o contraseña incorrectos.',
            'Incorrect username or password.',
          ),
        );
        return;
      }
      await CatalogScreen.restoreUserLibrary(user.userId);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) =>
              HomeScreen(displayName: user.displayName, userId: user.userId),
        ),
        (route) => false,
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(displayName: username),
      ),
      (route) => false,
    );
  }

  Future<void> _prepareGoogleSignIn() async {
    try {
      _googleSignInInitialization ??= GoogleSignIn.instance.initialize(
        clientId: kIsWeb ? _googleWebClientId : null,
        serverClientId: kIsWeb ? null : _googleWebClientId,
      );
      await _googleSignInInitialization;
      _googleSignInSubscription = GoogleSignIn.instance.authenticationEvents
          .listen((event) {
            unawaited(
              _handleGoogleAuthenticationEvent(event)
                  .catchError(_handleGoogleSignInError),
            );
          }, onError: _handleGoogleSignInError);
      if (mounted) setState(() => _googleSignInReady = true);
    } on GoogleSignInException catch (error, stackTrace) {
      _handleGoogleSignInError(error, stackTrace);
    } catch (error, stackTrace) {
      _handleGoogleSignInError(error, stackTrace);
    }
  }

  Future<void> _startNativeGoogleSignIn() async {
    if (!_supportsGoogleSignIn || kIsWeb) return;
    setState(() => _isSigningInWithGoogle = true);
    try {
      if (!_googleSignInReady) await _prepareGoogleSignIn();
      if (!_googleSignInReady) return;
      await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (error, stackTrace) {
      if (error.code != GoogleSignInExceptionCode.canceled) {
        _handleGoogleSignInError(error, stackTrace);
      }
    } finally {
      if (mounted) setState(() => _isSigningInWithGoogle = false);
    }
  }

  Future<void> _handleGoogleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    if (event case GoogleSignInAuthenticationEventSignIn(user: final account)) {
      setState(() => _isSigningInWithGoogle = true);
      try {
        final displayName = account.displayName ?? account.email;
        final user = kIsWeb
            ? await BooksmartDatabase.instance.signInWithGoogle(
                googleId: account.id,
                displayName: displayName,
                email: account.email,
              )
            : BooksmartUser(
                userId: account.id,
                displayName: displayName,
                username: account.email,
                email: account.email,
              );
        if (kIsWeb) await CatalogScreen.restoreUserLibrary(user.userId);
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) =>
                HomeScreen(displayName: user.displayName, userId: user.userId),
          ),
          (route) => false,
        );
      } finally {
        if (mounted) setState(() => _isSigningInWithGoogle = false);
      }
    }
  }

  void _handleGoogleSignInError(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'BookSmart Google sign-in',
      ),
    );
    if (mounted) {
      _showMessage(
        localizedText(
          context,
          'No se pudo completar el inicio de sesión con Google.',
          'Google sign-in could not be completed.',
        ),
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _downloadAndroidApp() async {
    final opened = await launchUrl(
      _androidAppDownloadUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      _showMessage(
        localizedText(
          context,
          'No se pudo abrir la descarga. Inténtalo de nuevo.',
          'Could not open the download. Please try again.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final useFullScreen =
        shouldUseFullScreenLayout(defaultTargetPlatform) || kIsWeb;
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final frameWidth = useFullScreen
            ? width
            : (width - 32).clamp(280.0, 440.0);
        final scale = useFullScreen
            ? (width / 600).clamp(0.82, 1.0)
            : (frameWidth / 375).clamp(0.68, 1.15);
        final logoSize = useFullScreen
            ? (height * 0.22).clamp(140.0, 190.0)
            : (frameWidth * 0.44).clamp(140.0, 205.0);

        return Center(
          child: Container(
            width: frameWidth,
            height: useFullScreen ? height : (height - 24).clamp(560.0, 900.0),
            padding: EdgeInsets.fromLTRB(
              useFullScreen ? 24 : 22 * scale,
              useFullScreen ? 42 : 30 * scale,
              useFullScreen ? 24 : 22 * scale,
              22 * scale,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2DB),
              border: useFullScreen
                  ? null
                  : Border.all(
                      color: const Color(0xFF39688F),
                      width: 9 * scale,
                    ),
              borderRadius: useFullScreen
                  ? null
                  : BorderRadius.circular(28 * scale),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(child: BookSmartEmblem(size: logoSize)),
                              SizedBox(height: 28 * scale),
                              Text(
                                localizedText(
                                  context,
                                  'Inicio de sesión:',
                                  'Sign in',
                                ),
                                style: TextStyle(
                                  fontSize: 23 * scale,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 22 * scale),
                              FieldLabel(
                                text: localizedText(
                                  context,
                                  'Usuario:',
                                  'Username:',
                                ),
                                scale: scale,
                              ),
                              SizedBox(height: 7 * scale),
                              LoginField(
                                controller: _usernameController,
                                scale: scale,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? localizedText(
                                        context,
                                        'Escribe tu usuario',
                                        'Enter your username',
                                      )
                                    : null,
                              ),
                              SizedBox(height: 20 * scale),
                              FieldLabel(
                                text: localizedText(
                                  context,
                                  'Contraseña:',
                                  'Password:',
                                ),
                                scale: scale,
                              ),
                              SizedBox(height: 7 * scale),
                              LoginField(
                                controller: _passwordController,
                                scale: scale,
                                obscureText: true,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? localizedText(
                                        context,
                                        'Escribe tu contraseña',
                                        'Enter your password',
                                      )
                                    : null,
                              ),
                              SizedBox(height: 20 * scale),
                              if (_supportsGoogleSignIn && kIsWeb)
                                Center(
                                  child: SizedBox(
                                    height: 48 * scale,
                                    child:
                                        _googleSignInReady &&
                                            !_isSigningInWithGoogle
                                        ? buildGoogleSignInButton(
                                            width: (frameWidth - 48 * scale)
                                                .clamp(240.0, 360.0),
                                            languageCode:
                                                Localizations.localeOf(context)
                                                    .languageCode,
                                          )
                                        : const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                  ),
                                )
                              else
                                SizedBox(
                                  width: double.infinity,
                                  height: 48 * scale,
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        !_isSigningInWithGoogle &&
                                            _supportsGoogleSignIn
                                        ? _startNativeGoogleSignIn
                                        : null,
                                    icon: Text(
                                      'G',
                                      style: TextStyle(
                                        fontSize: 25 * scale,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF4285F4),
                                      ),
                                    ),
                                    label: Text(
                                      localizedText(
                                        context,
                                        'Continuar con Google',
                                        'Continue with Google',
                                      ),
                                      style: TextStyle(
                                        fontSize: 17 * scale,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black87,
                                      side: const BorderSide(
                                        color: Color(0xFFB6C2CD),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          14 * scale,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(height: 12 * scale),
                              SizedBox(
                                width: double.infinity,
                                height: 47 * scale,
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF638DB1),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        28 * scale,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    localizedText(context, 'INICIO', 'SIGN IN'),
                                    style: TextStyle(
                                      fontSize: 20 * scale,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20 * scale),
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    localizedText(
                                      context,
                                      'Crear cuenta nueva',
                                      'Create a new account',
                                    ),
                                    style: TextStyle(
                                      color: const Color(0xFF00A7F4),
                                      fontSize: 19 * scale,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (kIsWeb)
                  SizedBox(
                    width: double.infinity,
                    height: 48 * scale,
                    child: OutlinedButton.icon(
                      onPressed: _downloadAndroidApp,
                      icon: const Icon(Icons.download),
                      label: Text(
                        localizedText(
                          context,
                          'Descargar app para Android',
                          'Download Android app',
                        ),
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF315D80),
                        side: const BorderSide(color: Color(0xFF638DB1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24 * scale),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    return Scaffold(body: useFullScreen ? body : SafeArea(child: body));
  }
}
