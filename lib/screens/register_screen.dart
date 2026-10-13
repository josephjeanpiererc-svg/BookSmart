import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _continueRegistration() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const EmailVerificationScreen(),
        ),
      );
    }
  }

  String? _requiredValue(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Escribe tu $label' : null;
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
            ? (height * 0.19).clamp(125.0, 175.0)
            : (frameWidth * 0.40).clamp(125.0, 185.0);

        return Center(
          child: Container(
            width: frameWidth,
            height: useFullScreen ? height : (height - 24).clamp(600.0, 920.0),
            padding: EdgeInsets.fromLTRB(
              useFullScreen ? 24 : 22 * scale,
              useFullScreen ? 28 : 24 * scale,
              useFullScreen ? 24 : 22 * scale,
              12 * scale,
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
                        SizedBox(height: 18 * scale),
                        Text(
                          'Crear una Nueva Cuenta:',
                          style: TextStyle(
                            fontSize: 23 * scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        FieldLabel(text: 'Nombre:', scale: scale),
                        SizedBox(height: 6 * scale),
                        LoginField(
                          controller: _nameController,
                          scale: scale,
                          validator: (value) => _requiredValue(value, 'nombre'),
                        ),
                        SizedBox(height: 12 * scale),
                        FieldLabel(text: 'Usuario:', scale: scale),
                        SizedBox(height: 6 * scale),
                        LoginField(
                          controller: _usernameController,
                          scale: scale,
                          validator: (value) =>
                              _requiredValue(value, 'usuario'),
                        ),
                        SizedBox(height: 12 * scale),
                        FieldLabel(text: 'Contraseña:', scale: scale),
                        SizedBox(height: 6 * scale),
                        LoginField(
                          controller: _passwordController,
                          scale: scale,
                          obscureText: true,
                          validator: (value) =>
                              _requiredValue(value, 'contraseña'),
                        ),
                        SizedBox(height: 12 * scale),
                        FieldLabel(text: 'Confirma Contraseña:', scale: scale),
                        SizedBox(height: 6 * scale),
                        LoginField(
                          controller: _confirmationController,
                          scale: scale,
                          obscureText: true,
                          validator: (value) {
                            final requiredError = _requiredValue(
                              value,
                              'contraseña',
                            );
                            if (requiredError != null) return requiredError;
                            return value == _passwordController.text
                                ? null
                                : 'Las contraseñas no coinciden';
                          },
                        ),
                        SizedBox(height: 16 * scale),
                        Center(
                          child: SizedBox(
                            width: (190 * scale).clamp(170.0, 250.0),
                            height: 42 * scale,
                            child: ElevatedButton(
                              onPressed: _continueRegistration,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF638DB1),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    24 * scale,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Continua...',
                                style: TextStyle(
                                  fontSize: 20 * scale,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text.rich(
                              TextSpan(
                                text: 'Volver a la parte de ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Inicio Sesión.',
                                    style: TextStyle(
                                      color: const Color(0xFF00A7F4),
                                      fontSize: 14 * scale,
                                    ),
                                  ),
                                ],
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

    return Scaffold(
      floatingActionButton: const ScreenCloseButton(),
      floatingActionButtonLocation: screenCloseButtonLocation,
      body: useFullScreen ? body : SafeArea(child: body),
    );
  }
}
