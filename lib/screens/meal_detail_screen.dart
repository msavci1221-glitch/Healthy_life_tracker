import 'dart:convert';
import 'package:flutter/material.dart';

class MealDetailScreen extends StatelessWidget {
  final Map<String, dynamic> meal;

  const MealDetailScreen({
    super.key,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    final foodName = (meal['foodName'] ?? 'Meal').toString();
    final calories = ((meal['calories'] ?? 0) as num).toDouble();
    final protein = (meal['protein'] as num?)?.toDouble() ?? 0;
    final carbs = (meal['carbs'] as num?)?.toDouble() ?? 0;
    final fat = (meal['fat'] as num?)?.toDouble() ?? 0;
    final analysisText = (meal['analysisText'] ?? '').toString();
    final base64Image = (meal['base64Image'] ?? '').toString();

    final imgBytes = base64Image.isNotEmpty ? base64Decode(base64Image) : null;

    // Mor tema renkleri
    const bg = Color(0xFFF7F2FF); // açık mor arka plan
    const purple = Color(0xFF6D28D9); // ana mor
    const purpleDark = Color(0xFF4C1D95); // koyu mor
    const card = Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: purple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          foodName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // ✅ FOTOĞRAF EN ÜSTTE
          Container(
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: purple.withOpacity(0.10)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: imgBytes != null
                    ? Image.memory(
                        imgBytes,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: const Color(0xFFF1E9FF),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.image_not_supported,
                                size: 44,
                                color: purpleDark,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No image available',
                                style: TextStyle(color: purpleDark),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ✅ FOTO ALTINA YEMEĞİN ADI
          Text(
            foodName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: purpleDark,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 10),

          // ✅ KPI / MACROS kartları (4 tane)
          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: 'Kcal',
                  value: calories.toStringAsFixed(0),
                  unit: 'kcal',
                  icon: Icons.local_fire_department_rounded,
                  accent: const Color(0xFFFF6B6B), // kırmızımsı
                  borderColor: purple.withOpacity(0.10),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  title: 'Protein',
                  value: protein.toStringAsFixed(0),
                  unit: 'gram',
                  icon: Icons.fitness_center_rounded,
                  accent: const Color(0xFF22C55E), // yeşil
                  borderColor: purple.withOpacity(0.10),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: 'Carbs',
                  value: carbs.toStringAsFixed(0),
                  unit: 'gram',
                  icon: Icons.bakery_dining_rounded,
                  accent: const Color(0xFFF59E0B), // turuncu
                  borderColor: purple.withOpacity(0.10),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  title: 'Fat',
                  value: fat.toStringAsFixed(0),
                  unit: 'gram',
                  icon: Icons.opacity_rounded,
                  accent: const Color(0xFF3B82F6), // mavi
                  borderColor: purple.withOpacity(0.10),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ✅ EN ALTA GEMINI YORUMU
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: purple.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: purple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: purple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Gemini Comment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: purpleDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  analysisText.isNotEmpty
                      ? analysisText
                      : 'No analysis text saved.',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.75),
                    height: 1.45,
                    fontSize: 14.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Tek tek: icon + değer + unit ayrı, kart güzel
  Widget _statCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color accent,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
