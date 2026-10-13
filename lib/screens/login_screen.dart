import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              HomeScreen(displayName: _usernameController.text.trim()),
        ),
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
                          'Inicio de sesión:',
                          style: TextStyle(
                            fontSize: 23 * scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 22 * scale),
                        FieldLabel(text: 'Usuario:', scale: scale),
                        SizedBox(height: 7 * scale),
                        LoginField(
                          controller: _usernameController,
                          scale: scale,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Escribe tu usuario'
                              : null,
                        ),
                        SizedBox(height: 20 * scale),
                        FieldLabel(text: 'Contraseña:', scale: scale),
                        SizedBox(height: 7 * scale),
                        LoginField(
                          controller: _passwordController,
                          scale: scale,
                          obscureText: true,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Escribe tu usuario'
                              : null,
                        ),
                        SizedBox(height: 20 * scale),
                        SizedBox(
                          width: double.infinity,
                          height: 48 * scale,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showMessage('Google estará disponible pronto'),
                            icon: Text(
                              'G',
                              style: TextStyle(
                                fontSize: 25 * scale,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF4285F4),
                              ),
                            ),
                            label: Text(
                              'Continuar con Google',
                              style: TextStyle(
                                fontSize: 17 * scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              side: const BorderSide(color: Color(0xFFB6C2CD)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14 * scale),
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
                                borderRadius: BorderRadius.circular(28 * scale),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'INICIO',
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
                              'Crear cuenta nueva',
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
        );
      },
    );

    return Scaffold(body: useFullScreen ? body : SafeArea(child: body));
  }
}
