import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/gemini_meal_result.dart';
import '../services/daily_progress_service.dart';
import '../flows/meal_analyze_flow.dart';
import '../services/local_notification_service.dart'; // 🔔 EKLENDİ
import '../utils/image_compress.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodAnalyzeTest extends StatefulWidget {
  const FoodAnalyzeTest({super.key});

  @override
  State<FoodAnalyzeTest> createState() => _FoodAnalyzeTestState();
}

class _FoodAnalyzeTestState extends State<FoodAnalyzeTest> {
  bool loading = false;
  String? rawText;
  String? error;

  File? _imageFile;
  GeminiMealResult? _result;

  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  double _pickCalories(Map<String, dynamic>? p) {
    if (p == null) return 0;
    final range = p["kcalRange"];
    if (range is List && range.length >= 2) {
      final a = (range[0] as num).toDouble();
      final b = (range[1] as num).toDouble();
      return (a + b) / 2.0;
    }
    return 0;
  }

  String _extractDishName(String raw) {
    final lines = raw.split('\n');

    for (final ln in lines) {
      final cleaned = ln.trim().replaceAll('*', '').trim();
      if (cleaned.toLowerCase().startsWith('dish name:')) {
        final name = cleaned.substring('dish name:'.length).trim();
        if (name.isNotEmpty) return name;
      }
    }
    for (final ln in lines) {
      final cleaned = ln.trim().replaceAll('*', '').trim();
      if (cleaned.toLowerCase().startsWith('dish:')) {
        final name = cleaned.substring('dish:'.length).trim();
        if (name.isNotEmpty) return name;
      }
    }
    return 'Meal';
  }

  Future<void> takePhotoAndAnalyze() async {
    safeSetState(() {
      loading = true;
      rawText = null;
      error = null;
      _result = null;
      _imageFile = null;
    });

    try {
      // 🔐 Firebase Auth (telefon fix)
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      final x = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 40, // 🔥 EN KRİTİK SATIR
        maxWidth: 800,
      );
      if (x == null) {
        safeSetState(() => loading = false);
        return;
      }

      final file = File(x.path);
      safeSetState(() {
        _imageFile = file;
      });

      final uri = Uri.parse(
        "https://food-api-vozt.onrender.com/api/analyze_food",
      );

      final req = http.MultipartRequest("POST", uri);
      req.files.add(await http.MultipartFile.fromPath("image", file.path));

      final res = await req.send();
      final body = await res.stream.bytesToString();

      if (res.statusCode != 200) {
        throw Exception("HTTP ${res.statusCode}: $body");
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      final raw = (json["rawText"] ?? "").toString();
      final parsed = json["parsed"] as Map<String, dynamic>?;

      final dishName = _extractDishName(raw);

      final geminiResult = GeminiMealResult(
        foodName: dishName,
        calories: _pickCalories(parsed),
        protein: (parsed?["proteinG"] as num?)?.toDouble() ?? 0,
        carbs: (parsed?["carbsG"] as num?)?.toDouble() ?? 0,
        fat: (parsed?["fatG"] as num?)?.toDouble() ?? 0,
      );

      // ✅ ANALYZE SONUCUNU HEMEN UI'YA YAZ
      safeSetState(() {
        rawText = raw;
        _result = geminiResult;
      });

      // 🔔 BİLDİRİM (KALORİ HESAPLANDIĞINDA)
      await LocalNotificationService.showMealResult(
        foodName: geminiResult.foodName,
        calories: geminiResult.calories,
      );

      // ✅ FIRESTORE SAVE AYRI (HATA VERSE BİLE UI BOZULMAZ)
      try {
        final service = DailyProgressService();
        final flow = MealAnalyzeFlow(service);

        await flow.handle(
          imageFile: file,
          geminiResult: geminiResult,
          analysisText: raw,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Saved to Food History")),
          );
        }
      } catch (e) {
        debugPrint('❌ Firestore save failed: $e');
      }
    } catch (e) {
      safeSetState(() {
        error = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Analyze Error: $e")),
        );
      }
    } finally {
      safeSetState(() {
        loading = false;
      });
    }
  }

  String _fmtNum(double? v, {int frac = 0, String empty = '-'}) {
    if (v == null) return empty;
    return v.toStringAsFixed(frac);
  }

  Widget _softCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 4),
            color: Color(0x12000000),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  Widget _statTile({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    const green = Color(0xFF22BFA2);

    return _softCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: green, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 9.5,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;

    final mealName =
        (r?.foodName.trim().isNotEmpty == true) ? r!.foodName : 'No meal yet';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Food Analyze',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _softCard(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: _imageFile == null
                                    ? Container(
                                        color: Colors.black.withOpacity(0.04),
                                        child: const Center(
                                          child: Icon(Icons.image_outlined,
                                              size: 42, color: Colors.black38),
                                        ),
                                      )
                                    : Image.file(_imageFile!,
                                        fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              mealName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.5,
                      children: [
                        _statTile(
                          title: 'Kcal',
                          value: _fmtNum(r?.calories),
                          unit: 'kcal',
                          icon: Icons.local_fire_department_rounded,
                        ),
                        _statTile(
                          title: 'Protein',
                          value: _fmtNum(r?.protein),
                          unit: 'g',
                          icon: Icons.fitness_center_rounded,
                        ),
                        _statTile(
                          title: 'Carbs',
                          value: _fmtNum(r?.carbs),
                          unit: 'g',
                          icon: Icons.grain_rounded,
                        ),
                        _statTile(
                          title: 'Fat',
                          value: _fmtNum(r?.fat),
                          unit: 'g',
                          icon: Icons.opacity_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _softCard(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gemini Comment',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              height: 200,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Text(
                                  error != null
                                      ? 'Error: $error'
                                      : (rawText?.trim().isNotEmpty == true
                                          ? rawText!.trim()
                                          : 'No analysis yet. Tap the button below to analyze.'),
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    height: 1.5,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : takePhotoAndAnalyze,
                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.camera_alt_rounded),
                  label: Text(
                    loading ? 'Analyzing...' : 'Foto Analyze',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22BFA2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
