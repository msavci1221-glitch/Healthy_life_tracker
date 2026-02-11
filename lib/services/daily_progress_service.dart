import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyProgressService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in (currentUser is null)');
    }
    return user.uid;
  }

  Future<void> setUserWeightKg(double weightKg) async {
    await _firestore.doc('users/$_uid/profile/main').set(
      {'weightKg': weightKg},
      SetOptions(merge: true),
    );
  }

  static String todayKey() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}-$mm-$dd';
  }

  // ✅ Transaction FIX: önce READ sonra WRITE
  Future<void> addMealBase64({
    required String dayKey,
    required String foodName,
    required double calories,
    double? protein,
    double? carbs,
    double? fat,
    required String base64Image,
    required String analysisText,
  }) async {
    final mealsRef = _firestore.collection('users/$_uid/daily/$dayKey/meals');
    final summaryRef = _firestore.doc('users/$_uid/daily/$dayKey/summary/main');

    await _firestore.runTransaction((tx) async {
      // 1) ✅ Önce oku
      final summarySnap = await tx.get(summaryRef);
      final currentTotal =
          ((summarySnap.data()?['totalCalories'] ?? 0) as num).toDouble();

      // 2) ✅ Sonra yaz (meal)
      tx.set(mealsRef.doc(), {
        'foodName': foodName,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'base64Image': base64Image,
        'analysisText': analysisText,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3) ✅ Sonra yaz (summary)
      tx.set(
        summaryRef,
        {'totalCalories': currentTotal + calories},
        SetOptions(merge: true),
      );
    });
  }

  Stream<double> totalCaloriesStream(String dayKey) {
    return _firestore
        .doc('users/$_uid/daily/$dayKey/summary/main')
        .snapshots()
        .map((doc) => ((doc.data()?['totalCalories'] ?? 0) as num).toDouble());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> mealsStream(String dayKey) {
    return _firestore
        .collection('users/$_uid/daily/$dayKey/meals')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
