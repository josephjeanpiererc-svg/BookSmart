import 'package:flutter/material.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({
    required this.locale,
    required this.onPressed,
    super.key,
  });

  final Locale locale;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isSpanish = locale.languageCode == 'es';
    return Material(
      color: const Color(0xFF638DB1),
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.language, size: 18),
        label: Text(isSpanish ? 'English' : 'Español'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
