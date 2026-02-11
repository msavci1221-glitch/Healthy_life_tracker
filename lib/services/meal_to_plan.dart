import '../ai/workout_ai_service.dart';
import '../ai/workout_plan_models.dart';
import '../ai/plan_builder.dart';
import '../ai/candidates_builder.dart';

double _parseWeight(dynamic v, {double fallback = 70}) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  if (v is String) {
    final x = double.tryParse(v.replaceAll(',', '.'));
    return x ?? fallback;
  }
  return fallback;
}

Future<WorkoutPlanResponse> generatePlanForMeal({
  required double mealCalories,
  required dynamic weightFromProfile, // firestore field
  double burnRatio = 0.8, // yemeğin %80'i yakılsın default
}) async {
  final weightKg = _parseWeight(weightFromProfile, fallback: 70);
  final targetCalories = mealCalories * burnRatio;

  final candidates = buildCandidatesFromLocalData();
  final byId = {for (final c in candidates) c.id: c};

  final service = WorkoutAIService(baseUrl: "http://10.0.2.2:5000");

  final draft = await service.generateDraft(
    request: WorkoutPlanRequest(
      targetCalories: targetCalories,
      weightKg: weightKg,
      candidates: candidates,
    ),
  );

  final plan = buildPlanFromDraft(
    draft: draft,
    targetCalories: targetCalories,
    weightKg: weightKg,
    byId: byId,
  );

  return plan;
}
