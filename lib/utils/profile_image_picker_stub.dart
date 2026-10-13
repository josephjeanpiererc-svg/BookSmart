import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickProfileImageImpl() async {
  final picker = ImagePicker();
  final file = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );

  if (file == null) {
    return null;
  }

  return file.readAsBytes();
}
