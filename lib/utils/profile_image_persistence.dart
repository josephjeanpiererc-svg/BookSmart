import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/booksmart_database.dart';

String _normalizedUserKey(String username) {
  final cleaned = username.trim();
  return cleaned.isEmpty ? 'usuario_default' : cleaned.toLowerCase();
}

String _profileImageKey(String username) =>
    'profile_image_${_normalizedUserKey(username)}';

Future<void> saveProfileImageForUser(
  String username,
  Uint8List imageBytes,
) async {
  if (kIsWeb) {
    await BooksmartDatabase.instance.saveProfileImage(
      _normalizedUserKey(username),
      imageBytes,
    );
    return;
  }
  final prefs = await SharedPreferences.getInstance();
  final base64Image = base64Encode(imageBytes);
  await prefs.setString(_profileImageKey(username), base64Image);
}

Future<Uint8List?> loadProfileImageForUser(String username) async {
  if (kIsWeb) {
    final bytes = await BooksmartDatabase.instance.loadProfileImage(
      _normalizedUserKey(username),
    );
    return bytes == null ? null : Uint8List.fromList(bytes);
  }
  final prefs = await SharedPreferences.getInstance();
  final base64Image = prefs.getString(_profileImageKey(username));
  if (base64Image == null || base64Image.isEmpty) {
    return null;
  }

  try {
    return base64Decode(base64Image);
  } catch (_) {
    return null;
  }
}
