import 'workout_plan_models.dart';
import 'met_calculator.dart';

WorkoutPlanResponse buildPlanFromDraft({
  required DraftPlanResponse draft,
  required double targetCalories,
  required double weightKg,
  required Map<String, CandidateExercise> byId,
  int maxItems = 5,
}) {
  final items = <WorkoutPlanItem>[];

  // Güvenli seçim: draft -> local data eşle
  for (final d in draft.items) {
    if (items.length >= maxItems) break;

    final c = byId[d.id];
    if (c == null) continue;

    final minutes = d.minutes.clamp(5.0, 20.0);
    final sets = d.sets.clamp(1, 8);
    final reps = d.reps.clamp(5, 30);

    items.add(
      WorkoutPlanItem(
        id: c.id,
        name: c.name,
        met: c.met,
        minutes: minutes,
        sets: sets,
        reps: reps,
        note: d.note,
      ),
    );
  }

  // Eğer AI boş döndürdüyse: en iyi 3 egzersizle fallback
  if (items.isEmpty) {
    final top = byId.values.toList()..sort((a, b) => b.met.compareTo(a.met));
    for (final c in top.take(3)) {
      items.add(
        WorkoutPlanItem(
          id: c.id,
          name: c.name,
          met: c.met,
          minutes: 10,
          sets: 3,
          reps: 10,
          note: 'Auto fallback (AI draft empty).',
        ),
      );
    }
  }

  // Toplamları hesapla
  final totalMinutes = items.fold<double>(0, (s, e) => s + e.minutes);
  final totalCalories = calcPlanCalories(weightKg: weightKg, items: items);

  return WorkoutPlanResponse(
    planTitle: draft.title,
    totalMinutes: totalMinutes,
    totalCalories: totalCalories,
    items: items,
  );
}
