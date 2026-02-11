import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/daily_progress_service.dart';
import 'meal_detail_screen.dart';

class FoodHistoryScreen extends StatelessWidget {
  const FoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = DailyProgressService();
    final dayKey = DailyProgressService.todayKey();

    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: const Text('Food History'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: service.mealsStream(dayKey),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // ✅ total'ı listeden hesapla -> silince anında düşer
          final total = docs.fold<double>(0, (sum, d) {
            final m = d.data();
            final c = (m['calories'] as num?)?.toDouble() ?? 0;
            return sum + c;
          });

          return Column(
            children: [
              Expanded(
                child: Builder(
                  builder: (_) {
                    // ✅ Empty state
                    if (docs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.restaurant_rounded,
                                size: 72,
                                color: Colors.deepPurple.withOpacity(0.55),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No meals saved yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'When you analyze a meal, it will appear here.\nYou can swipe left to delete it.',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.55),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final m = doc.data();

                        final foodName = (m['foodName'] ?? 'Meal').toString();
                        final calories =
                            (m['calories'] as num?)?.toDouble() ?? 0;
                        final protein = (m['protein'] as num?)?.toDouble() ?? 0;
                        final carbs = (m['carbs'] as num?)?.toDouble() ?? 0;
                        final fat = (m['fat'] as num?)?.toDouble() ?? 0;

                        final base64Image = (m['base64Image'] ?? '').toString();
                        final imgBytes = base64Image.isNotEmpty
                            ? base64Decode(base64Image)
                            : null;

                        return Dismissible(
                          key: ValueKey(doc.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) async {
                            await doc.reference.delete();
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MealDetailScreen(meal: m),
                                  ),
                                );
                              },
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: imgBytes != null
                                    ? Image.memory(
                                        imgBytes,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      )
                                    : const SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: Icon(Icons.image_not_supported),
                                      ),
                              ),
                              title: Text(
                                foodName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${calories.toStringAsFixed(0)} kcal'
                                ' • P ${protein.toStringAsFixed(0)}g'
                                ' • C ${carbs.toStringAsFixed(0)}g'
                                ' • F ${fat.toStringAsFixed(0)}g',
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await doc.reference.delete();
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // ✅ TOTAL CALORIES (altta)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text('🔥', style: TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Total Calories',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          '${total.toStringAsFixed(0)} kcal',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
