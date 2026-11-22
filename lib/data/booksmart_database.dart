import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast_web/sembast_web.dart';

class BooksmartUser {
  const BooksmartUser({
    required this.userId,
    required this.displayName,
    required this.username,
    required this.email,
  });

  final String userId;
  final String displayName;
  final String username;
  final String email;
}

class BookLibraryData {
  BookLibraryData({
    Iterable<String> owned = const [],
    Iterable<String> reading = const [],
    Iterable<String> completed = const [],
    Iterable<String> pending = const [],
    Iterable<String> favorites = const [],
  }) : owned = owned.toSet(),
       reading = reading.toSet(),
       completed = completed.toSet(),
       pending = pending.toSet(),
       favorites = favorites.toSet();

  final Set<String> owned;
  final Set<String> reading;
  final Set<String> completed;
  final Set<String> pending;
  final Set<String> favorites;

  factory BookLibraryData.fromMap(Map<String, Object?>? map) {
    Set<String> readSet(String key) =>
        (map?[key] as List<Object?>? ?? const []).whereType<String>().toSet();

    return BookLibraryData(
      owned: readSet('owned'),
      reading: readSet('reading'),
      completed: readSet('completed'),
      pending: readSet('pending'),
      favorites: readSet('favorites'),
    );
  }

  Map<String, Object?> toMap() => {
    'owned': owned.toList(),
    'reading': reading.toList(),
    'completed': completed.toList(),
    'pending': pending.toList(),
    'favorites': favorites.toList(),
  };
}

class BooksmartDatabase {
  BooksmartDatabase._(this._factory, this._name);

  static final BooksmartDatabase instance = BooksmartDatabase._(
    databaseFactoryWeb,
    'booksmart.db',
  );

  @visibleForTesting
  BooksmartDatabase.forTesting(DatabaseFactory factory, String name)
    : this._(factory, name);

  final DatabaseFactory _factory;
  final String _name;
  Database? _database;
  final _users = stringMapStoreFactory.store('users');

  Future<Database> get _db async =>
      _database ??= await _factory.openDatabase(_name);

  static String _usernameKey(String username) => username.trim().toLowerCase();

  Future<bool> usernameExists(String username) async {
    final key = _usernameKey(username);
    if (key.isEmpty) return false;
    final db = await _db;
    return await _users.record(key).exists(db);
  }

  Future<BooksmartUser> createPasswordAccount({
    required String displayName,
    required String username,
    required String email,
    required String password,
  }) async {
    final key = _usernameKey(username);
    if (key.isEmpty) {
      throw ArgumentError.value(username, 'username', 'Must not be empty.');
    }

    final db = await _db;
    if (await _users.record(key).exists(db)) {
      throw UsernameAlreadyExistsException();
    }

    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final hash = await _derivePasswordHash(password, salt);
    final record = <String, Object?>{
      'displayName': displayName.trim(),
      'username': username.trim(),
      'email': email.trim().toLowerCase(),
      'provider': 'password',
      'passwordSalt': salt,
      'passwordHash': hash,
      'library': BookLibraryData().toMap(),
      'profileImage': null,
    };

    await _users.record(key).put(db, record);
    return BooksmartUser(
      userId: key,
      displayName: displayName.trim(),
      username: username.trim(),
      email: email.trim().toLowerCase(),
    );
  }

  Future<BooksmartUser?> authenticatePassword({
    required String username,
    required String password,
  }) async {
    final key = _usernameKey(username);
    final db = await _db;
    final record = await _users.record(key).get(db);
    if (record == null || record['provider'] != 'password') return null;

    final salt = (record['passwordSalt'] as List<Object?>?)?.cast<int>();
    final savedHash = (record['passwordHash'] as List<Object?>?)?.cast<int>();
    if (salt == null || savedHash == null) return null;

    final candidate = await _derivePasswordHash(password, salt);
    if (!_constantTimeEquals(candidate, savedHash)) return null;

    return BooksmartUser(
      userId: key,
      displayName: record['displayName'] as String? ?? username.trim(),
      username: record['username'] as String? ?? username.trim(),
      email: record['email'] as String? ?? '',
    );
  }

  Future<BooksmartUser> signInWithGoogle({
    required String googleId,
    required String displayName,
    required String email,
  }) async {
    final key = 'google:$googleId';
    final db = await _db;
    final oldRecord = await _users.record(key).get(db);
    final record = <String, Object?>{
      ...?oldRecord,
      'displayName': displayName.trim().isEmpty ? email : displayName.trim(),
      'username': email.trim().toLowerCase(),
      'email': email.trim().toLowerCase(),
      'provider': 'google',
      'googleId': googleId,
      'library': oldRecord?['library'] ?? BookLibraryData().toMap(),
      'profileImage': oldRecord?['profileImage'],
    };
    await _users.record(key).put(db, record);
    return BooksmartUser(
      userId: key,
      displayName: record['displayName'] as String,
      username: record['username'] as String,
      email: record['email'] as String,
    );
  }

  Future<BookLibraryData> loadLibrary(String userId) async {
    final db = await _db;
    final record = await _users.record(userId).get(db);
    final library = record?['library'];
    if (library is! Map) return BookLibraryData();
    return BookLibraryData.fromMap(Map<String, Object?>.from(library));
  }

  Future<BooksmartUser?> loadUser(String userId) async {
    final db = await _db;
    final record = await _users.record(userId).get(db);
    if (record == null) return null;

    return BooksmartUser(
      userId: userId,
      displayName: record['displayName'] as String? ?? '',
      username: record['username'] as String? ?? '',
      email: record['email'] as String? ?? '',
    );
  }

  Future<void> saveLibrary(String userId, BookLibraryData library) async {
    final db = await _db;
    final record = await _users.record(userId).get(db);
    if (record == null) {
      throw StateError('Cannot save a library for an unknown account.');
    }
    await _users.record(userId).update(db, {'library': library.toMap()});
  }

  Future<void> saveProfileImage(String userId, List<int> bytes) async {
    final db = await _db;
    final record = await _users.record(userId).get(db);
    if (record == null) {
      throw StateError('Cannot save a profile image for an unknown account.');
    }
    await _users.record(userId).update(db, {
      'profileImage': base64Encode(bytes),
    });
  }

  Future<List<int>?> loadProfileImage(String userId) async {
    final db = await _db;
    final record = await _users.record(userId).get(db);
    final image = record?['profileImage'];
    if (image is! String || image.isEmpty) return null;
    return base64Decode(image);
  }

  Future<List<int>> _derivePasswordHash(String password, List<int> salt) async {
    final key = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 120000,
      bits: 256,
    ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
    return key.extractBytes();
  }

  bool _constantTimeEquals(List<int> first, List<int> second) {
    if (first.length != second.length) return false;
    var difference = 0;
    for (var index = 0; index < first.length; index++) {
      difference |= first[index] ^ second[index];
    }
    return difference == 0;
  }

  @visibleForTesting
  Future<void> closeForTesting() async {
    await _database?.close();
    _database = null;
  }
}

class UsernameAlreadyExistsException implements Exception {
  const UsernameAlreadyExistsException();
}
