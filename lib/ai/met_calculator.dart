import 'workout_plan_models.dart';

double caloriesForExercise({
  required double met,
  required double weightKg,
  required double minutes,
}) {
  if (met <= 0 || weightKg <= 0 || minutes <= 0) return 0;
  return (met * weightKg * minutes) / 60.0;
}

double calcPlanCalories({
  required double weightKg,
  required List<WorkoutPlanItem> items,
}) {
  double sum = 0;
  for (final it in items) {
    sum += caloriesForExercise(
        met: it.met, weightKg: weightKg, minutes: it.minutes);
  }
  return sum;
}
