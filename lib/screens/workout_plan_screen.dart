import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/daily_progress_service.dart';
import '../data/workout_data.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  WorkoutPlanResponse? _plan;
  bool _loadingPlan = false;
  String? _planError;

  // ✅ kullanıcı yaptıkça buradan silecek
  List<WorkoutPlanItem> _remainingItems = [];

  @override
  Widget build(BuildContext context) {
    final service = DailyProgressService();
    final dayKey = DailyProgressService.todayKey();

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Workout Plan'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder(
        stream: service.mealsStream(dayKey),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // ✅ FoodHistory ile birebir aynı hesap
          final total = docs.fold<double>(0, (sum, d) {
            final m = d.data();
            final c = (m['calories'] as num?)?.toDouble() ?? 0;
            return sum + c;
          });

          final targetCalories = total * 0.8;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '🔥 Total Calories Today: ${total.toStringAsFixed(0)} kcal',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '🤖 Workout Plan',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Target burn: ${targetCalories.toStringAsFixed(0)} kcal (total * 0.8)',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: _loadingPlan
                            ? null
                            : () async {
                                if (total <= 0) {
                                  setState(() {
                                    _planError =
                                        'Bugün total calorie 0 görünüyor. Önce meal ekle.';
                                    _plan = null;
                                    _remainingItems = [];
                                  });
                                  return;
                                }

                                setState(() {
                                  _loadingPlan = true;
                                  _planError = null;
                                });

                                try {
                                  final weightKg = await _getUserWeightKg();
                                  final candidates =
                                      buildCandidatesFromLocalData();

                                  final plan = await generatePlanFromBackend(
                                    baseUrl:
                                        'http://10.0.2.2:5000', // 🔥 BURASI
                                    targetCalories: targetCalories,
                                    weightKg: weightKg,
                                    candidates: candidates,
                                  );

                                  setState(() {
                                    _plan = plan;
                                    _remainingItems =
                                        List<WorkoutPlanItem>.from(plan.items);
                                    _planError = null;
                                  });
                                } catch (e) {
                                  setState(() {
                                    _planError = e.toString();
                                    _plan = null;
                                    _remainingItems = [];
                                  });
                                } finally {
                                  setState(() => _loadingPlan = false);
                                }
                              },
                        icon: _loadingPlan
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(
                            _loadingPlan ? 'Generating...' : 'Generate plan'),
                      ),
                      if (_planError != null) ...[
                        const SizedBox(height: 10),
                        Text('Error: $_planError',
                            style: const TextStyle(color: Colors.red)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (_plan != null) ...[
                Text(
                  _plan!.planTitle,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                if (_remainingItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        '✅ All workouts completed!',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                else
                  ..._remainingItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final e = entry.value;

                    return Dismissible(
                      key: ValueKey('${e.id}-$index'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        setState(() {
                          _remainingItems.removeAt(index);
                        });
                      },
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.fitness_center),
                          title: Text(e.name),
                          subtitle: Text(
                            '${e.minutes.toStringAsFixed(0)} min'
                            ' • MET ${e.met.toStringAsFixed(1)}'
                            '${(e.sets != null && e.reps != null) ? ' • ${e.sets}x${e.reps}' : ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.green),
                            onPressed: () {
                              setState(() {
                                _remainingItems.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<double> _getUserWeightKg() async {
    // senin placeholder mantığın aynı
    return 70;
  }
}

/// -------------------- MODELS + HELPERS (senin kodun aynen) --------------------

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
