class CandidateExercise {
  final String id;
  final String name;
  final double met;

  const CandidateExercise({
    required this.id,
    required this.name,
    required this.met,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "met": met,
      };
}

class WorkoutPlanRequest {
  final double targetCalories;
  final double weightKg;
  final List<CandidateExercise> candidates;

  const WorkoutPlanRequest({
    required this.targetCalories,
    required this.weightKg,
    required this.candidates,
  });

  Map<String, dynamic> toJson() => {
        "targetCalories": targetCalories,
        "weightKg": weightKg,
        "candidates": candidates.map((c) => c.toJson()).toList(),
      };
}

// Gemini'nin döndüreceği basit taslak (id + minutes + sets/reps önerisi)
class DraftPlanItem {
  final String id;
  final double minutes;
  final int sets;
  final int reps;
  final String note;

  const DraftPlanItem({
    required this.id,
    required this.minutes,
    required this.sets,
    required this.reps,
    this.note = '',
  });

  factory DraftPlanItem.fromJson(Map<String, dynamic> json) => DraftPlanItem(
        id: (json['id'] ?? '').toString(),
        minutes: (json['minutes'] is num)
            ? (json['minutes'] as num).toDouble()
            : 8.0,
        sets: (json['sets'] is num) ? (json['sets'] as num).toInt() : 3,
        reps: (json['reps'] is num) ? (json['reps'] as num).toInt() : 10,
        note: (json['note'] ?? '').toString(),
      );
}

class DraftPlanResponse {
  final String title;
  final List<DraftPlanItem> items;

  const DraftPlanResponse({required this.title, required this.items});

  factory DraftPlanResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json['items'] as List?) ?? const [];
    return DraftPlanResponse(
      title: (json['title'] ?? 'Workout Plan').toString(),
      items: raw
          .map(
              (e) => DraftPlanItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

// Uygulamada kullanacağımız nihai plan
class WorkoutPlanItem {
  final String id;
  final String name;
  final double met;
  final double minutes;
  final int sets;
  final int reps;
  final String note;

  const WorkoutPlanItem({
    required this.id,
    required this.name,
    required this.met,
    required this.minutes,
    required this.sets,
    required this.reps,
    this.note = '',
  });
}

class WorkoutPlanResponse {
  final String planTitle;
  final double totalMinutes;
  final double totalCalories;
  final List<WorkoutPlanItem> items;

  const WorkoutPlanResponse({
    required this.planTitle,
    required this.totalMinutes,
    required this.totalCalories,
    required this.items,
  });
}
