import 'package:flutter/material.dart';
import '../data/workout_data.dart';
import '../widgets/local_cached_image.dart';
import '../widgets/exercise_video_player.dart';

class WorkoutItemScreen extends StatefulWidget {
  final ExerciseItem exercise;
  const WorkoutItemScreen({super.key, required this.exercise});

  @override
  State<WorkoutItemScreen> createState() => _WorkoutItemScreenState();
}

class _WorkoutItemScreenState extends State<WorkoutItemScreen> {
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _repsController.dispose();
    _setsController.dispose();
    _durationController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Widget _buildChips(List<String> items) => Wrap(
        spacing: 8,
        runSpacing: 6,
        children: items
            .map((t) =>
                Chip(label: Text(t, style: const TextStyle(fontSize: 12))))
            .toList(),
      );

  Widget _decoratedSection({
    required String title,
    required IconData icon,
    required Widget child,
    Color? accent,
  }) {
    final a = accent ?? const Color.fromRGBO(239, 83, 80, 1);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: a.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: a.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: a.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: a, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: a,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _compactStat(String label, String value, IconData icon,
      {Color? accent}) {
    final a = accent ?? const Color.fromRGBO(239, 83, 80, 1);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: a.withOpacity(0.18), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: a, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: a)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          )
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, {Color? color}) {
    final accent = color ?? const Color(0xFFFF5252);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.18), width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: accent)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900, color: accent),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          )
        ],
      ),
    );
  }

  Widget _instructorCard(List<String> steps) {
    return Column(
      children: steps.asMap().entries.map((e) {
        final idx = e.key + 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step $idx',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(e.value,
                    style: const TextStyle(fontSize: 14, height: 1.45)),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.exercise;

    final bodyPart = item.resolvedBodyPart;
    final equipment = item.resolvedEquipment;
    final instructions = item.resolvedInstructions;

    final videoUrl = (item.videoUrl ?? '').trim();
    final imageUrl = item.imageUrl.trim();

    String descriptionRaw = item.resolvedDescription;

    List<String> keywordsFromDesc = [];
    final km = RegExp(r'Keywords:\s*(.*?)\s*(?:\n\n|\z)',
            dotAll: true, caseSensitive: false)
        .firstMatch(descriptionRaw);

    if (km != null) {
      keywordsFromDesc = km
          .group(1)!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      descriptionRaw = descriptionRaw.replaceAll(km.group(0)!, '').trim();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F6),
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: const Color(0xFFFF5252),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),

            /// VIDEO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _decoratedSection(
                title: 'Workout Video',
                icon: Icons.play_circle_outline,
                child: SizedBox(
                  height: 260,
                  child: videoUrl.isNotEmpty
                      ? ExerciseVideo(url: videoUrl)
                      : imageUrl.isNotEmpty
                          ? LocalCachedImage(url: imageUrl)
                          : const Center(child: Text('No demo available')),
                ),
              ),
            ),

            /// MAIN CONTENT
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      if (bodyPart.isNotEmpty)
                        _compactStat('Body', bodyPart, Icons.accessibility_new),
                      const SizedBox(width: 10),
                      if (equipment.isNotEmpty)
                        _compactStat(
                            'Equipment', equipment, Icons.fitness_center),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// CALCULATOR
                  _decoratedSection(
                    title: 'Estimate Calories',
                    icon: Icons.local_fire_department_outlined,
                    child: Builder(builder: (_) {
                      double minutes = 0;
                      final d = _durationController.text.trim();
                      if (d.isNotEmpty) {
                        minutes = double.tryParse(d) ?? 0;
                      } else {
                        minutes = item.estimateMinutesFromRepsSets(
                          reps: int.tryParse(_repsController.text) ?? 0,
                          sets: int.tryParse(_setsController.text) ?? 0,
                        );
                      }
                      final weight =
                          double.tryParse(_weightController.text) ?? 70;
                      final kcal = item.estimateCalories(
                          weightKg: weight, minutes: minutes);

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _repsController,
                                  decoration:
                                      const InputDecoration(labelText: 'Reps'),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _setsController,
                                  decoration:
                                      const InputDecoration(labelText: 'Sets'),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _durationController,
                                  decoration: const InputDecoration(
                                      labelText: 'Duration (minutes)'),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _weightController,
                                  decoration: const InputDecoration(
                                      labelText: 'Weight (kg)'),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _statCard(
                                    'Duration',
                                    '${minutes.toStringAsFixed(2)} min',
                                    Icons.schedule),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _statCard(
                                    'Est. kcal',
                                    '${kcal.toStringAsFixed(1)} kcal',
                                    Icons.local_fire_department),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ),

                  const SizedBox(height: 12),

                  /// DESCRIPTION
                  _decoratedSection(
                    title: 'Description',
                    icon: Icons.insert_drive_file_outlined,
                    child: Text(descriptionRaw.isEmpty
                        ? 'No description yet.'
                        : descriptionRaw),
                  ),

                  if (keywordsFromDesc.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _decoratedSection(
                      title: 'Keywords',
                      icon: Icons.label_outline,
                      child: _buildChips(keywordsFromDesc),
                    ),
                  ],

                  if (item.tips.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _decoratedSection(
                      title: 'Tips',
                      icon: Icons.lightbulb_outline,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: item.tips.map((t) => Text('• $t')).toList(),
                      ),
                    ),
                  ],

                  if (item.variations.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _decoratedSection(
                      title: 'Variations',
                      icon: Icons.swap_horiz_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            item.variations.map((v) => Text('• $v')).toList(),
                      ),
                    ),
                  ],

                  if (instructions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _decoratedSection(
                      title: 'Instructor',
                      icon: Icons.school,
                      child: _instructorCard(instructions.take(4).toList()),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
