import '../data/workout_data.dart';
import 'workout_plan_models.dart';

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
