import 'package:flutter/material.dart';

import '../utils/app_localization.dart';
import 'booksmart_widgets.dart';

class BookDetailsSheet extends StatelessWidget {
  const BookDetailsSheet({
    required this.book,
    required this.imagePath,
    required this.qrAssetPath,
    required this.scale,
    required this.status,
    required this.isFavorite,
    required this.isOwned,
    required this.onStatusChanged,
    required this.onFavoriteChanged,
    required this.onAddToLibrary,
    super.key,
  });

  final (String, String, String, String, String) book;
  final String imagePath;
  final String qrAssetPath;
  final double scale;
  final BookReadingStatus status;
  final bool isFavorite;
  final bool isOwned;
  final ValueChanged<BookReadingStatus> onStatusChanged;
  final ValueChanged<bool> onFavoriteChanged;
  final VoidCallback onAddToLibrary;

  static void show({
    required BuildContext context,
    required (String, String, String, String, String) book,
    required String imagePath,
    required String qrAssetPath,
    required double scale,
    required BookReadingStatus status,
    required bool isFavorite,
    required bool isOwned,
    required ValueChanged<BookReadingStatus> onStatusChanged,
    required ValueChanged<bool> onFavoriteChanged,
    required VoidCallback onAddToLibrary,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookDetailsSheet(
        book: book,
        imagePath: imagePath,
        qrAssetPath: qrAssetPath,
        scale: scale,
        status: status,
        isFavorite: isFavorite,
        isOwned: isOwned,
        onStatusChanged: onStatusChanged,
        onFavoriteChanged: onFavoriteChanged,
        onAddToLibrary: onAddToLibrary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = book.$2;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28 * scale)),
      ),
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        18 * scale,
        18 * scale,
        22 * scale,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 52 * scale,
                height: 6 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD6E5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            SizedBox(height: 16 * scale),
            SizedBox(
              height: 240 * scale,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18 * scale),
                child: BookCoverImage(path: imagePath),
              ),
            ),
            SizedBox(height: 18 * scale),
            Text(
              title,
              style: TextStyle(
                fontSize: 26 * scale,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E2A39),
              ),
            ),
            SizedBox(height: 10 * scale),
            BookQrCard(assetPath: qrAssetPath, title: title, scale: scale),
            SizedBox(height: 12 * scale),
            Text(
              localizedText(context, 'Descripción', 'Description'),
              style: TextStyle(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2B3A4D),
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              book.$3,
              style: TextStyle(
                fontSize: 15 * scale,
                color: const Color(0xFF4C5663),
                height: 1.4,
              ),
            ),
            SizedBox(height: 16 * scale),
            _DetailInfoRow(
              label: localizedText(
                context,
                'Fecha de publicación',
                'Publication date',
              ),
              value: book.$4,
              scale: scale,
            ),
            SizedBox(height: 10 * scale),
            _DetailInfoRow(
              label: localizedText(
                context,
                '¿De qué se trata?',
                'About this book',
              ),
              value: book.$5,
              scale: scale,
            ),
            SizedBox(height: 18 * scale),
            BookStatusControls(
              scale: scale,
              status: status,
              isFavorite: isFavorite,
              onStatusChanged: onStatusChanged,
              onFavoriteChanged: onFavoriteChanged,
            ),
            SizedBox(height: 18 * scale),
            SizedBox(
              width: double.infinity,
              height: 48 * scale,
              child: ElevatedButton(
                key: ValueKey('detail_add_button_$title'),
                onPressed: isOwned ? null : onAddToLibrary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOwned
                      ? const Color(0xFFBFBFBF)
                      : const Color(0xFFF0C94D),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                ),
                child: Text(
                  isOwned
                      ? localizedText(
                          context,
                          'Ya está en tu posesión',
                          'Already in your library',
                        )
                      : localizedText(
                          context,
                          'Añadir a la biblioteca',
                          'Add to library',
                        ),
                  style: TextStyle(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.label,
    required this.value,
    required this.scale,
  });

  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2B3A4D),
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          value,
          style: TextStyle(
            fontSize: 14 * scale,
            color: const Color(0xFF495A6D),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
