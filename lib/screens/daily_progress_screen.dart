import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/daily_progress_service.dart';
import 'meal_detail_screen.dart';

// ✅ Local workout data (workoutCategories burada olmalı)
import '../data/workout_data.dart';

class DailyProgressScreen extends StatefulWidget {
  const DailyProgressScreen({super.key});

  @override
  State<DailyProgressScreen> createState() => _DailyProgressScreenState();
}

class _DailyProgressScreenState extends State<DailyProgressScreen> {
  WorkoutPlanResponse? _plan;
  bool _loadingPlan = false;
  String? _planError;

  @override
  Widget build(BuildContext context) {
    final service = DailyProgressService();
    final dayKey = DailyProgressService.todayKey();

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Progress')),
      body: StreamBuilder<double>(
        stream: service.totalCaloriesStream(dayKey),
        builder: (context, totalSnap) {
          final total = totalSnap.data ?? 0;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '🔥 Total Calories Today: ${total.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              // ✅ AI PLAN CARD (DailyProgress’in içine gömülü)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _AiPlanCard(
                  totalCaloriesToday: total,
                  loading: _loadingPlan,
                  errorText: _planError,
                  plan: _plan,
                  onGenerate: () async {
                    if (total <= 0) {
                      setState(() {
                        _planError =
                            'Bugün total calorie 0 görünüyor. Önce meal ekle.';
                        _plan = null;
                      });
                      return;
                    }

                    setState(() {
                      _loadingPlan = true;
                      _planError = null;
                    });

                    try {
                      final weightKg =
                          await _getUserWeightKg(); // ✅ profile’dan alacağın yer
                      final targetCalories = total * 0.8; // default %80

                      final candidates = buildCandidatesFromLocalData();
                      final plan = await generatePlanFromBackend(
                        baseUrl: 'http://10.0.2.2:5000',
                        targetCalories: targetCalories,
                        weightKg: weightKg,
                        candidates: candidates,
                      );

                      setState(() {
                        _plan = plan;
                        _planError = null;
                      });
                    } catch (e) {
                      setState(() {
                        _planError = e.toString();
                        _plan = null;
                      });
                    } finally {
                      setState(() => _loadingPlan = false);
                    }
                  },
                ),
              ),

              const Divider(),

              // ✅ MEALS LIST (seninki aynen)
              Expanded(
                child: StreamBuilder(
                  stream: service.mealsStream(dayKey),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(child: Text('No meals added today.'));
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final m = docs[i].data();

                        final foodName = (m['foodName'] ?? 'Meal').toString();
                        final calories =
                            ((m['calories'] ?? 0) as num).toDouble();
                        final protein = (m['protein'] as num?)?.toDouble() ?? 0;
                        final carbs = (m['carbs'] as num?)?.toDouble() ?? 0;
                        final fat = (m['fat'] as num?)?.toDouble() ?? 0;

                        final base64Image = (m['base64Image'] ?? '').toString();
                        final imgBytes = base64Image.isNotEmpty
                            ? base64Decode(base64Image)
                            : null;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => MealDetailScreen(meal: m)),
                              );
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: imgBytes != null
                                  ? Image.memory(imgBytes,
                                      width: 56, height: 56, fit: BoxFit.cover)
                                  : const SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: Icon(Icons.image_not_supported),
                                    ),
                            ),
                            title: Text(foodName),
                            subtitle: Text(
                              '${calories.toStringAsFixed(0)} kcal'
                              ' • P ${protein.toStringAsFixed(0)}g'
                              ' • C ${carbs.toStringAsFixed(0)}g'
                              ' • F ${fat.toStringAsFixed(0)}g',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ✅ Burayı Firestore profile alanına bağlayacaksın.
  /// Şimdilik 70 döndürüyorum ki ekran patlamasın.
  Future<double> _getUserWeightKg() async {
    // TODO: Firestore’dan user weight çek:
    // final uid = FirebaseAuth.instance.currentUser!.uid;
    // final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    // return (doc.data()?['weightKg'] as num?)?.toDouble() ?? 70;
    return 70;
  }
}

/// -------------------- UI CARD --------------------

class _AiPlanCard extends StatelessWidget {
  final double totalCaloriesToday;
  final bool loading;
  final String? errorText;
  final WorkoutPlanResponse? plan;
  final VoidCallback onGenerate;

  const _AiPlanCard({
    required this.totalCaloriesToday,
    required this.loading,
    required this.errorText,
    required this.plan,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final target = totalCaloriesToday * 0.8;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🤖 AI Workout Plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Target burn: ${target.toStringAsFixed(0)} kcal  (today total * 0.8)',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: loading ? null : onGenerate,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(loading ? 'Generating...' : 'Generate plan'),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                'Error: $errorText',
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (plan != null) ...[
              const SizedBox(height: 12),
              Text(
                plan!.planTitle,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...plan!.items.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.fitness_center, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${e.name} — ${e.minutes.toStringAsFixed(0)} min'
                          ' • MET ${e.met.toStringAsFixed(1)}'
                          '${(e.sets != null && e.reps != null) ? ' • ${e.sets}x${e.reps}' : ''}',
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

/// -------------------- MODELS + HELPERS (tek dosyada çalışsın diye) --------------------

class CandidateExercise {
  final String id;
  final String name;
  final double met;

  CandidateExercise({required this.id, required this.name, required this.met});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'met': met};
}

class WorkoutPlanItem {
  final String id;
  final String name;
  final double met;
  final double minutes;
  final int? sets;
  final int? reps;
  final String note;

  WorkoutPlanItem({
    required this.id,
    required this.name,
    required this.met,
    required this.minutes,
    this.sets,
    this.reps,
    this.note = '',
  });

  factory WorkoutPlanItem.fromJson(Map<String, dynamic> j) => WorkoutPlanItem(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        met: ((j['met'] ?? 0) as num).toDouble(),
        minutes: ((j['minutes'] ?? 0) as num).toDouble(),
        sets: (j['sets'] as num?)?.toInt(),
        reps: (j['reps'] as num?)?.toInt(),
        note: (j['note'] ?? '').toString(),
      );
}

class WorkoutPlanResponse {
  final String planTitle;
  final double totalMinutes;
  final List<WorkoutPlanItem> items;

  WorkoutPlanResponse({
    required this.planTitle,
    required this.totalMinutes,
    required this.items,
  });

  factory WorkoutPlanResponse.fromJson(Map<String, dynamic> j) {
    final arr = (j['items'] as List?) ?? const [];
    return WorkoutPlanResponse(
      planTitle: (j['planTitle'] ?? 'Workout Plan').toString(),
      totalMinutes: ((j['totalMinutes'] ?? 0) as num).toDouble(),
      items: arr
          .map((e) => WorkoutPlanItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

/// ✅ Local workout_data.dart içindeki workoutCategories’den MET’li adaylar çıkarır
List<CandidateExercise> buildCandidatesFromLocalData() {
  final list = <CandidateExercise>[];
  for (final cat in workoutCategories) {
    for (final ex in cat.items) {
      if (ex.met <= 0) continue;
      list.add(CandidateExercise(id: ex.id, name: ex.name, met: ex.met));
    }
  }
  return list;
}

/// ✅ Flask/Gemini backend’den plan alır
Future<WorkoutPlanResponse> generatePlanFromBackend({
  required String baseUrl,
  required double targetCalories,
  required double weightKg,
  required List<CandidateExercise> candidates,
}) async {
  final url = Uri.parse('$baseUrl/api/workout_plan');

  final body = jsonEncode({
    'targetCalories': targetCalories,
    'weightKg': weightKg,
    'candidates': candidates.map((e) => e.toJson()).toList(),
  });

  final res = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (res.statusCode != 200) {
    throw Exception('Backend error ${res.statusCode}: ${res.body}');
  }

  final decoded = jsonDecode(res.body);
  return WorkoutPlanResponse.fromJson(Map<String, dynamic>.from(decoded));
}
