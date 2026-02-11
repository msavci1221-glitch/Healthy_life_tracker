import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../models/gemini_meal_result.dart';
import '../services/daily_progress_service.dart';

class MealAnalyzeFlow {
  final DailyProgressService _service;

  MealAnalyzeFlow(this._service);

  Future<void> handle({
    required File imageFile,
    required GeminiMealResult geminiResult,
    required String analysisText,
  }) async {
    final dayKey = DailyProgressService.todayKey();

    // 🔍 LOG 1: Orijinal dosya boyutu
    final originalBytes = await imageFile.length();
    print('📸 Original image bytes: $originalBytes');

    // ✅ FOTOĞRAFI SIKIŞTIR (TELEFON FIX)
    final compressed = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      quality: 60,
      minWidth: 1024,
    );

    if (compressed == null) {
      throw Exception('❌ Image compression failed (compressed == null)');
    }

    // 🔍 LOG 2: Sıkıştırılmış byte
    print('📉 Compressed image bytes: ${compressed.length}');

    // ✅ base64 (artık küçük ve güvenli)
    final base64Image = base64Encode(compressed);

    // 🔍 LOG 3: base64 uzunluğu (Firestore kritik)
    print('🧬 Base64 length: ${base64Image.length}');

    // ⚠️ Güvenlik sınırı (Firestore ~1MB)
    if (base64Image.length > 900000) {
      throw Exception('❌ Base64 too large for Firestore');
    }

    // ✅ FIRESTORE'A YAZ
    await _service.addMealBase64(
      dayKey: dayKey,
      foodName: geminiResult.foodName,
      calories: geminiResult.calories,
      protein: geminiResult.protein,
      carbs: geminiResult.carbs,
      fat: geminiResult.fat,
      base64Image: base64Image,
      analysisText: analysisText,
    );

    // 🔍 LOG 4: başarı
    print('✅ Meal saved to Firestore successfully');
  }
}
