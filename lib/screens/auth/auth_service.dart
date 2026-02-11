import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // LOGIN
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // 🔴 KRİTİK: displayName cache yenile
    await cred.user?.reload();
  }

  // REGISTER
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // 🔴 GERÇEK İSİM BURAYA YAZILIR
    await cred.user?.updateDisplayName(fullName.trim());

    // 🔴 CACHE GÜNCELLE
    await cred.user?.reload();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String errorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email is already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'network-request-failed':
        return 'No internet connection';
      default:
        return e.message ?? 'Unknown error';
    }
  }
}
