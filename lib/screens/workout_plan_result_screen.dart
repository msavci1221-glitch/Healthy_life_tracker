import 'package:flutter/material.dart';
import '../ai/workout_plan_models.dart';
import '../services/meal_to_plan.dart';

class WorkoutPlanResultScreen extends StatelessWidget {
  final double mealCalories;
  final dynamic weightFromProfile;

  const WorkoutPlanResultScreen({
    super.key,
    required this.mealCalories,
    required this.weightFromProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Workout Plan")),
      body: FutureBuilder<WorkoutPlanResponse>(
        future: generatePlanForMeal(
          mealCalories: mealCalories,
          weightFromProfile: weightFromProfile,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "AI plan failed:\n${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final plan = snapshot.data;
          if (plan == null || plan.items.isEmpty) {
            return const Center(child: Text("Plan empty."));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text(
                plan.planTitle,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Total minutes: ${plan.totalMinutes.toStringAsFixed(0)}"),
              const SizedBox(height: 12),
              ...plan.items.map((e) => Card(
                    child: ListTile(
                      title: Text(e.name),
                      subtitle: Text(
                        "MET: ${e.met} • Minutes: ${e.minutes.toStringAsFixed(0)}"
                        "${(e.sets > 0 && e.reps > 0) ? " • ${e.sets}x${e.reps}" : ""}",
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
