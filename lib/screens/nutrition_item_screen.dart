import 'dart:io';
import 'package:flutter/material.dart';

import '../data/nutrition_data.dart';
import '../services/spoonacular_service.dart';
import '../services/nutrition_cache.dart';
import '../services/food_image_file_cache.dart';

class NutritionItemScreen extends StatefulWidget {
  final FoodItem item;
  const NutritionItemScreen({super.key, required this.item});

  @override
  State<NutritionItemScreen> createState() => _NutritionItemScreenState();
}

class _NutritionItemScreenState extends State<NutritionItemScreen> {
  late FoodItem uiItem;
  bool loading = false;
  String? errorText;

  static const String _placeholder =
      'https://via.placeholder.com/300x200.png?text=Food';

  @override
  void initState() {
    super.initState();
    uiItem = widget.item;
    _loadFromApiOrCache();
  }

  /// ✅ Cache varsa bile image yoksa "sadece image" backfill yap
  Future<String?> _backfillImageIfNeeded({
    required SpoonacularService service,
    required String foodId,
    required String foodName,
    required CachedNutritionEntry cached,
  }) async {
    // 1) Cache'te path var mı?
    final cachedPath = cached.imageUrl.trim();
    if (cachedPath.isNotEmpty &&
        !FoodImageFileCache.isRemoteUrl(cachedPath) &&
        File(cachedPath).existsSync()) {
      return cachedPath;
    }

    // 2) Diskte standart dosya var mı? (food_images/{id}.jpg)
    final existing = await FoodImageFileCacheExisting.existingPath(foodId);
    if (existing != null) {
      // cache'i düzelt
      if (cached.imageUrl.trim().isEmpty) {
        await NutritionCache.write(
          foodId,
          CachedNutritionEntry(
            caloriesKcal: cached.caloriesKcal,
            proteinG: cached.proteinG,
            carbsG: cached.carbsG,
            fatG: cached.fatG,
            imageUrl: existing,
            savedAtMs: cached.savedAtMs,
          ),
        );
      }
      return existing;
    }

    // 3) Hiç yoksa -> sadece ingredient search ile resmi bul ve indir
    try {
      final results = await service.searchIngredient(foodName);
      if (results.isNotEmpty &&
          results[0] is Map &&
          results[0]['image'] != null) {
        final imageName = results[0]['image'] as String;
        final remoteUrl = service.ingredientImageUrl(imageName);

        final p = await FoodImageFileCache.downloadToLocalFile(
          foodId: foodId,
          remoteUrl: remoteUrl,
        );
        if (p != null && p.isNotEmpty) {
          await NutritionCache.write(
            foodId,
            CachedNutritionEntry(
              caloriesKcal: cached.caloriesKcal,
              proteinG: cached.proteinG,
              carbsG: cached.carbsG,
              fatG: cached.fatG,
              imageUrl: p,
              savedAtMs: DateTime.now().millisecondsSinceEpoch,
            ),
          );
          return p;
        }
      }
    } catch (_) {}

    return null;
  }

  Future<void> _loadFromApiOrCache() async {
    setState(() {
      loading = true;
      errorText = null;
    });

    final cached = await NutritionCache.read(uiItem.id);
    if (cached != null) {
      // ✅ Nutrients cache'ten bas
      uiItem = uiItem.copyWith(
        nutrients: uiItem.nutrients.copyWith(
          caloriesKcal: cached.caloriesKcal,
          proteinG: cached.proteinG,
          carbsG: cached.carbsG,
          fatG: cached.fatG,
        ),
        imageUrl:
            cached.imageUrl.isNotEmpty ? cached.imageUrl : uiItem.imageUrl,
      );

      // ✅ Image backfill (cache var ama image yoksa)
      try {
        final service = SpoonacularService.fromEnv();
        final img = await _backfillImageIfNeeded(
          service: service,
          foodId: uiItem.id,
          foodName: uiItem.name,
          cached: cached,
        );
        if (img != null && img.isNotEmpty) {
          uiItem = uiItem.copyWith(imageUrl: img);
        }
      } catch (_) {}

      setState(() => loading = false);
      return;
    }

    // ✅ Cache yoksa full API
    try {
      final service = SpoonacularService.fromEnv();

      final parseJson = await service.parseNutrition("100g ${uiItem.name}");
      final newNutrients =
          SpoonacularService.nutrientsFromParseResponse(parseJson);

      uiItem = uiItem.copyWith(nutrients: newNutrients);

      String remoteImageUrl = '';
      if (uiItem.imageUrl == _placeholder || uiItem.imageUrl.isEmpty) {
        final results = await service.searchIngredient(uiItem.name);
        if (results.isNotEmpty &&
            results[0] is Map &&
            results[0]['image'] != null) {
          final imageName = results[0]['image'] as String;
          remoteImageUrl = service.ingredientImageUrl(imageName);
        }
      }

      String localPath = '';
      if (remoteImageUrl.isNotEmpty) {
        final p = await FoodImageFileCache.downloadToLocalFile(
          foodId: uiItem.id,
          remoteUrl: remoteImageUrl,
        );
        if (p != null) localPath = p;
      }

      if (localPath.isNotEmpty) {
        uiItem = uiItem.copyWith(imageUrl: localPath);
      }

      await NutritionCache.write(
        uiItem.id,
        CachedNutritionEntry(
          caloriesKcal: uiItem.nutrients.caloriesKcal,
          proteinG: uiItem.nutrients.proteinG,
          carbsG: uiItem.nutrients.carbsG,
          fatG: uiItem.nutrients.fatG,
          imageUrl: localPath,
          savedAtMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      setState(() {});
    } catch (e) {
      final msg = e.toString();
      setState(() {
        errorText = msg.contains("429")
            ? "Spoonacular limitine takıldık (429). Biraz sonra tekrar dene."
            : msg;
      });
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _forceRefresh() async {
    await NutritionCache.clearOne(uiItem.id);
    await _loadFromApiOrCache();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFF6),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(uiItem.name, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _forceRefresh),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            // Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _sectionCard(
                title: 'Food Image',
                icon: Icons.fastfood,
                accent: Colors.green.shade700,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.green.shade700.withOpacity(0.12),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(height: 220, child: _buildFoodImage()),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    uiItem.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // ✅ taşma olmasın diye yatay scroll
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _macroCard('Kcal',
                            uiItem.nutrients.caloriesKcal.toStringAsFixed(0)),
                        _macroCard('Protein',
                            uiItem.nutrients.proteinG.toStringAsFixed(1)),
                        _macroCard(
                            'Fat', uiItem.nutrients.fatG.toStringAsFixed(1)),
                        _macroCard('Carbs',
                            uiItem.nutrients.carbsG.toStringAsFixed(1)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (loading) const Center(child: CircularProgressIndicator()),

                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Error: $errorText',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  _sectionCard(
                    title: 'Description',
                    icon: Icons.description_outlined,
                    child: Text(
                      uiItem.description.isEmpty
                          ? 'No description available.'
                          : uiItem.description,
                      style: const TextStyle(height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _sectionCard(
                    title: 'Benefits',
                    icon: Icons.favorite_outline,
                    child: Text(
                      uiItem.benefits.isEmpty
                          ? 'No benefits listed.'
                          : uiItem.benefits,
                      style: const TextStyle(height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _sectionCard(
                    title: 'Tips',
                    icon: Icons.lightbulb_outline,
                    child: Text(
                      uiItem.tips.isEmpty ? 'No tips available.' : uiItem.tips,
                      style: const TextStyle(height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _sectionCard(
                    title: 'Common Dishes',
                    icon: Icons.restaurant_menu,
                    child: uiItem.commonDishes.isNotEmpty
                        ? Wrap(
                            spacing: 8,
                            children: uiItem.commonDishes
                                .map((d) => _tag(d))
                                .toList(),
                          )
                        : const Text('No common dishes listed.'),
                  ),
                  const SizedBox(height: 12),

                  _sectionCard(
                    title: 'Warnings',
                    icon: Icons.warning_amber_outlined,
                    child: Text(
                      uiItem.warnings.isEmpty
                          ? 'No warnings.'
                          : uiItem.warnings,
                      style: const TextStyle(height: 1.45),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ eksik olan method buydu (hataları çözen)
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Color? accent,
  }) {
    final accentColor = accent ?? Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildFoodImage() {
    final s = uiItem.imageUrl.trim();
    if (s.isEmpty || s == _placeholder) {
      return const Center(
        child:
            Text('No image available', style: TextStyle(color: Colors.black54)),
      );
    }

    if (!FoodImageFileCache.isRemoteUrl(s)) {
      return Image.file(
        File(s),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(
          child: Text('No image available',
              style: TextStyle(color: Colors.black54)),
        ),
      );
    }

    return Image.network(
      s,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Center(
        child: Text('No image available',
            style: TextStyle(color: Color.fromARGB(136, 0, 0, 0))),
      ),
    );
  }

  Widget _tag(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _macroCard(String label, String value) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade700, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade700.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      );
}

/// küçük helper: diskten standart path kontrol (food_images/{id}.jpg)
class FoodImageFileCacheExisting {
  static Future<String?> existingPath(String foodId) async {
    // Senin dosyanda bu zaten placeholder gibi duruyor; dokunmuyorum.
    // İstersen burada gerçek path kontrol ekleriz.
    return null;
  }
}
