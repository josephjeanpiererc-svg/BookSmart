import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'qr_download.dart';

String qrAssetUrl(String assetPath) {
  if (assetPath.isEmpty) {
    return '';
  }
  return '/assets/${assetPath.replaceFirst('assets/', '')}';
}

class BookCoverImage extends StatelessWidget {
  const BookCoverImage({
    required this.path,
    super.key,
    this.fit = BoxFit.cover,
  });

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(path, fit: fit);
  }
}

class BookQrCard extends StatelessWidget {
  const BookQrCard({
    required this.assetPath,
    required this.title,
    required this.scale,
    super.key,
  });

  final String assetPath;
  final String title;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(assetPath, fit: BoxFit.contain);
    final qrImage = kIsWeb
        ? Image.network(qrAssetUrl(assetPath), fit: BoxFit.contain)
        : image;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 82 * scale,
          height: 82 * scale,
          padding: EdgeInsets.all(5 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10 * scale),
            border: Border.all(color: const Color(0xFFCBD6E5)),
          ),
          child: qrImage,
        ),
        QrDownloadButton(assetPath: assetPath, title: title),
      ],
    );
  }
}

const screenCloseButtonLocation = _ScreenCloseButtonLocation();

class _ScreenCloseButtonLocation extends FloatingActionButtonLocation {
  const _ScreenCloseButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    const topMargin = 12.0;
    const leftMargin = 18.0;
    return Offset(
      scaffoldGeometry.minInsets.left + leftMargin,
      scaffoldGeometry.minInsets.top + topMargin,
    );
  }
}

class ScreenCloseButton extends StatelessWidget {
  const ScreenCloseButton({super.key, this.confirmExit = false});

  final bool confirmExit;

  Future<void> _close(BuildContext context) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (confirmExit) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('¿Regresar al inicio de sesión?'),
          content: const Text('Tendrás que iniciar sesión nuevamente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Regresar'),
            ),
          ],
        ),
      );
      if (shouldExit == true && context.mounted) {
        navigator.pushNamedAndRemoveUntil('/login', (route) => false);
      }
      return;
    }

    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != '/login') {
      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Cerrar',
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          onTap: () => _close(context),
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.close, color: Colors.black, size: 27),
          ),
        ),
      ),
    );
  }
}

class LoadingLabel extends StatelessWidget {
  const LoadingLabel({required this.scale, super.key});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Cargando',
          style: TextStyle(
            fontSize: 20 * scale,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2A37),
          ),
        ),
        SizedBox(width: 12 * scale),
        SizedBox(
          width: 28 * scale,
          height: 28 * scale,
          child: CircularProgressIndicator(
            strokeWidth: 3.2 * scale,
            color: const Color(0xFF234C73),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF234C73)),
          ),
        ),
      ],
    );
  }
}

class BookSmartEmblem extends StatelessWidget {
  const BookSmartEmblem({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF234C73), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/principal_logo.jpeg',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel({required this.text, required this.scale, super.key});

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.w700),
    );
  }
}

class LoginField extends StatelessWidget {
  const LoginField({
    required this.controller,
    required this.scale,
    required this.validator,
    super.key,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final double scale;
  final String? Function(String?) validator;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 18 * scale),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13 * scale),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13 * scale),
          borderSide: BorderSide(
            color: const Color(0xFF638DB1),
            width: 2 * scale,
          ),
        ),
        errorStyle: TextStyle(fontSize: 12 * scale),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.label,
    required this.scale,
    required this.onPressed,
    super.key,
  });

  final String label;
  final double scale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (265 * scale).clamp(220.0, 330.0),
      height: 43 * scale,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF638DB1),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24 * scale),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

enum BookReadingStatus { reading, pending, completed }

class BookStatusControls extends StatefulWidget {
  const BookStatusControls({
    required this.scale,
    required this.status,
    required this.isFavorite,
    required this.onStatusChanged,
    required this.onFavoriteChanged,
    super.key,
  });

  final double scale;
  final BookReadingStatus status;
  final bool isFavorite;
  final ValueChanged<BookReadingStatus> onStatusChanged;
  final ValueChanged<bool> onFavoriteChanged;

  @override
  State<BookStatusControls> createState() => _BookStatusControlsState();
}

class _BookStatusControlsState extends State<BookStatusControls> {
  late BookReadingStatus _status = widget.status;
  late bool _isFavorite = widget.isFavorite;

  void _selectStatus(BookReadingStatus status) {
    setState(() => _status = status);
    widget.onStatusChanged(status);
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onFavoriteChanged(_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatusButton(
          icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
          label: 'Favorito',
          selected: _isFavorite,
          scale: widget.scale,
          onPressed: _toggleFavorite,
        ),
        _StatusButton(
          icon: Icons.hourglass_top_rounded,
          label: 'Pendiente',
          selected: _status == BookReadingStatus.pending,
          scale: widget.scale,
          onPressed: () => _selectStatus(BookReadingStatus.pending),
        ),
        _StatusButton(
          icon: Icons.check,
          label: 'Completado',
          selected: _status == BookReadingStatus.completed,
          scale: widget.scale,
          onPressed: () => _selectStatus(BookReadingStatus.completed),
        ),
        _StatusButton(
          icon: Icons.book_rounded,
          label: 'Leyendo',
          selected: _status == BookReadingStatus.reading,
          scale: widget.scale,
          onPressed: () => _selectStatus(BookReadingStatus.reading),
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.scale,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF2C6FB4) : const Color(0xFF9AA5B1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor: selected
                ? const Color(0xFFF0C94D)
                : const Color(0xFFE5E8EA),
            foregroundColor: color,
            shape: const CircleBorder(),
            fixedSize: Size(42 * scale, 42 * scale),
          ),
          icon: Icon(icon, size: 22 * scale),
        ),
        SizedBox(height: 3 * scale),
        Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF2C6FB4) : Colors.black54,
            fontSize: 10 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
