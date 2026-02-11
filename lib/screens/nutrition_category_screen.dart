import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../data/nutrition_data.dart';
import '../services/nutrition_cache.dart';
import '../services/food_image_file_cache.dart';
import '../services/spoonacular_service.dart';
import 'nutrition_item_screen.dart';

/// ===============================
/// CATEGORY LIST SCREEN (RESİMLİ)
/// ===============================
class NutritionCategoryScreen extends StatelessWidget {
  const NutritionCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFF6),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text(
          'Nutrition Categories',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 24),
        itemCount: nutritionCategories.length,
        itemBuilder: (context, index) {
          final category = nutritionCategories[index];
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    NutritionCategoryDetailScreen(category: category),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              height: 210, // Yüksekliği artırıldı
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage(category.imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.18),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  category.name,
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

/// ==================================
/// CATEGORY DETAIL SCREEN (GRID)
/// ==================================
class NutritionCategoryDetailScreen extends StatefulWidget {
  final NutritionCategory category;
  const NutritionCategoryDetailScreen({super.key, required this.category});

  @override
  State<NutritionCategoryDetailScreen> createState() =>
      _NutritionCategoryDetailScreenState();
}

class _NutritionCategoryDetailScreenState
    extends State<NutritionCategoryDetailScreen> {
  Future<String?> _diskImageIfExists(String foodId) async {
    try {
      final path =
          '${(await getApplicationDocumentsDirectory()).path}/food_images/$foodId.jpg';
      final f = File(path);
      return await f.exists() ? path : null;
    } catch (_) {
      return null;
    }
  }

  /// ✅ Grid için en iyi resmi bul:
  /// 1) cache.imageUrl -> dosya varsa göster
  /// 2) yoksa disk standard path -> varsa göster + cache varsa cache'i düzelt
  /// 3) yoksa API -> indir -> cache varsa cache'i düzelt -> göster
  Future<String?> _gridBestImagePath(FoodItem item) async {
    final cached = await NutritionCache.read(item.id);
    final cachedPath = (cached?.imageUrl ?? '').trim();

    // 1) Cache path varsa ve dosya varsa
    if (cachedPath.isNotEmpty &&
        !FoodImageFileCache.isRemoteUrl(cachedPath) &&
        File(cachedPath).existsSync()) {
      return cachedPath;
    }

    // 2) Diskte standart dosya var mı?
    final disk = await _diskImageIfExists(item.id);
    if (disk != null) {
      // cache'i iyileştir (sadece cache varsa!)
      if (cached != null && cached.imageUrl.trim().isEmpty) {
        await NutritionCache.write(
          item.id,
          CachedNutritionEntry(
            caloriesKcal: cached.caloriesKcal,
            proteinG: cached.proteinG,
            carbsG: cached.carbsG,
            fatG: cached.fatG,
            imageUrl: disk,
            savedAtMs: cached.savedAtMs,
          ),
        );
      }
      return disk;
    }

    // 3) Diskte yoksa -> sadece image için API backfill
    try {
      final service = SpoonacularService.fromEnv();

      final results = await service.searchIngredient(item.name);
      if (results.isNotEmpty &&
          results[0] is Map &&
          results[0]['image'] != null) {
        final imageName = results[0]['image'] as String;
        final remoteUrl = service.ingredientImageUrl(imageName);

        final p = await FoodImageFileCache.downloadToLocalFile(
          foodId: item.id,
          remoteUrl: remoteUrl,
        );

        if (p != null && p.isNotEmpty) {
          // cache varsa nutrients'ı koruyarak path'i yaz
          if (cached != null) {
            await NutritionCache.write(
              item.id,
              CachedNutritionEntry(
                caloriesKcal: cached.caloriesKcal,
                proteinG: cached.proteinG,
                carbsG: cached.carbsG,
                fatG: cached.fatG,
                imageUrl: p,
                savedAtMs: DateTime.now().millisecondsSinceEpoch,
              ),
            );
          }
          return p;
        }
      }
    } catch (_) {}

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FFF6),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(
          category.name,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: category.items.length,
        itemBuilder: (context, index) {
          final item = category.items[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NutritionItemScreen(item: item),
                ),
              );

              // ✅ geri dönünce kesin yenile
              if (!mounted) return;
              setState(() {});
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// IMAGE
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: FutureBuilder<String?>(
                          future: _gridBestImagePath(item),
                          builder: (context, snapshot) {
                            final path = (snapshot.data ?? '').trim();

                            if (path.isNotEmpty && File(path).existsSync()) {
                              return Image.file(
                                File(path),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported),
                              );
                            }

                            return const Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.black45,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  /// NAME
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      item.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
