import 'package:flutter/material.dart';
import '../data/workout_data.dart';
import 'workout_category_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mapping category names to asset images
    final Map<String, String> categoryImages = {
      'Chest Exercises': 'assets/workout/image/chest exercise.png',
      'Back Exercises': 'assets/workout/image/back exercise.png',
      'Leg Exercises': 'assets/workout/image/leg exercise.png',
      'Shoulder Exercises': 'assets/workout/image/shoulder exercise.png',
      'Arm Exercises': 'assets/workout/image/arm exercise.png',
      'Core / Abs Exercises': 'assets/workout/image/core abs exercise.png',
      'Cardio Exercises': 'assets/workout/image/cardio exercise.png',
      'Full Body Exercises': 'assets/workout/image/full body exercise.png',
    };
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F6),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(239, 83, 80, 1),
        title: const Text(
          'Workout',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 24),
        itemCount: workoutCategories.length,
        itemBuilder: (context, index) {
          final cat = workoutCategories[index];
          final imagePath = categoryImages[cat.name] ?? '';
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WorkoutCategoryScreen(category: cat),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              height: 210, // Yüksekliği artırıldı
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 255, 255, 255)
                        .withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                image: imagePath.isNotEmpty
                    ? DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.18),
                          BlendMode.darken,
                        ),
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  cat.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 8, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
