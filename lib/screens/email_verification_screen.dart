import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import 'account_created_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _codeFocusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _codeFocusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final focusNode in _codeFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _getCode() {
    if (_emailController.text.trim().isEmpty) {
      _formKey.currentState?.validate();
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Código enviado a tu correo')));
  }

  void _verifyEmail() {
    final hasCode = _codeControllers.every(
      (controller) => controller.text.trim().isNotEmpty,
    );
    if (_formKey.currentState!.validate() && hasCode) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const AccountCreatedScreen()),
      );
    } else if (!hasCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe los 6 dígitos del código')),
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
            ? (height * 0.18).clamp(120.0, 170.0)
            : (frameWidth * 0.38).clamp(120.0, 175.0);

        return Center(
          child: Container(
            width: frameWidth,
            height: useFullScreen ? height : (height - 24).clamp(580.0, 900.0),
            padding: EdgeInsets.fromLTRB(
              useFullScreen ? 24 : 22 * scale,
              useFullScreen ? 28 : 24 * scale,
              useFullScreen ? 24 : 22 * scale,
              18 * scale,
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
                        SizedBox(height: 14 * scale),
                        Center(
                          child: Text(
                            'Verificación de correo',
                            style: TextStyle(
                              fontSize: 23 * scale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 16 * scale),
                        VerificationCodeRow(
                          controllers: _codeControllers,
                          focusNodes: _codeFocusNodes,
                          scale: scale,
                        ),
                        SizedBox(height: 28 * scale),
                        FieldLabel(text: 'Correo:', scale: scale),
                        SizedBox(height: 6 * scale),
                        LoginField(
                          controller: _emailController,
                          scale: scale,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Escribe tu correo';
                            }
                            if (!value.contains('@')) {
                              return 'Escribe un correo válido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 18 * scale),
                        Center(
                          child: ActionButton(
                            label: 'Obtener Código',
                            scale: scale,
                            onPressed: _getCode,
                          ),
                        ),
                        SizedBox(height: 16 * scale),
                        Center(
                          child: Icon(
                            Icons.mark_email_read,
                            color: const Color(0xFF76A5F0),
                            size: 66 * scale,
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        Center(
                          child: ActionButton(
                            label: 'Verificar correo',
                            scale: scale,
                            onPressed: _verifyEmail,
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

class VerificationCodeRow extends StatelessWidget {
  const VerificationCodeRow({
    required this.controllers,
    required this.focusNodes,
    required this.scale,
    super.key,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var index = 0; index < controllers.length; index++)
          SizedBox(
            width: 42 * scale,
            height: 42 * scale,
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              keyboardType: TextInputType.number,
              maxLength: 1,
              textAlign: TextAlign.center,
              onChanged: (value) {
                if (value.isNotEmpty && index < controllers.length - 1) {
                  focusNodes[index + 1].requestFocus();
                } else if (value.isEmpty && index > 0) {
                  focusNodes[index - 1].requestFocus();
                }
              },
              style: TextStyle(
                fontSize: 20 * scale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF17202A),
              ),
              cursorColor: const Color(0xFF39688F),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFFFFBF3),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                  borderSide: BorderSide(color: Color(0xFFD0D7DE)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                  borderSide: BorderSide(color: Color(0xFFD0D7DE)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                  borderSide: BorderSide(color: Color(0xFF39688F), width: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
