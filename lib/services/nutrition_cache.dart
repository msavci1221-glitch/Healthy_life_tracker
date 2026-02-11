import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CachedNutritionEntry {
  final double caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String imageUrl; // boş olabilir
  final int savedAtMs; // epoch ms

  CachedNutritionEntry({
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.imageUrl,
    required this.savedAtMs,
  });

  Map<String, dynamic> toJson() => {
        "caloriesKcal": caloriesKcal,
        "proteinG": proteinG,
        "carbsG": carbsG,
        "fatG": fatG,
        "imageUrl": imageUrl,
        "savedAtMs": savedAtMs,
      };

  static CachedNutritionEntry fromJson(Map<String, dynamic> json) {
    double d(dynamic v) => v is num ? v.toDouble() : 0.0;
    return CachedNutritionEntry(
      caloriesKcal: d(json["caloriesKcal"]),
      proteinG: d(json["proteinG"]),
      carbsG: d(json["carbsG"]),
      fatG: d(json["fatG"]),
      imageUrl: (json["imageUrl"] ?? "") as String,
      savedAtMs:
          (json["savedAtMs"] is num) ? (json["savedAtMs"] as num).toInt() : 0,
    );
  }
}

class NutritionCache {
  // İstersen 7 gün yap. Ben 3 gün öneriyorum.
  static const Duration ttl = Duration(days: 3650);

  static String _keyForFood(String foodId) => "nutri_cache_v1_$foodId";

  static Future<CachedNutritionEntry?> read(String foodId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForFood(foodId));
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final entry = CachedNutritionEntry.fromJson(map);

      final now = DateTime.now().millisecondsSinceEpoch;
      final ageMs = now - entry.savedAtMs;
      if (ageMs > ttl.inMilliseconds) {
        // TTL geçtiyse cache'i sil
        await prefs.remove(_keyForFood(foodId));
        return null;
      }

      return entry;
    } catch (_) {
      // Bozuk cache varsa sil
      await prefs.remove(_keyForFood(foodId));
      return null;
    }
  }

  static Future<void> write(String foodId, CachedNutritionEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyForFood(foodId), jsonEncode(entry.toJson()));
  }

  static Future<void> clearOne(String foodId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForFood(foodId));
  }
}
