import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🔐 Firebase Auth user
User? get currentUser => FirebaseAuth.instance.currentUser;

/// 🆔 User ID
String get currentUserId => currentUser?.uid ?? '';

/// 👤 Kullanıcı adı
String get currentUserName =>
    currentUser?.displayName?.trim().isNotEmpty == true
        ? currentUser!.displayName!
        : 'User';

/// 🖼️ Profil foto
String? get currentUserPhoto => currentUser?.photoURL;

/// 🕒 Zaman formatı
String formatTime(Timestamp? ts) {
  if (ts == null) return '';
  final diff = DateTime.now().difference(ts.toDate());

  if (diff.inSeconds < 30) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  return '${diff.inDays} d ago';
}

/// 🧠 Base64 güvenli decode
Uint8List? decodeBase64(dynamic value) {
  try {
    if (value == null || value is! String || value.isEmpty) return null;
    return base64Decode(value);
  } catch (_) {
    return null;
  }
}
