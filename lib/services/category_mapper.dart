import '../data/nutrition_data.dart';

class CategoryMapper {
  static final _keywords = <String, String>{
    'meat': 'meat',
    'chicken': 'meat',
    'beef': 'meat',
    'lamb': 'meat',
    'fish': 'fish',
    'salmon': 'fish',
    'tuna': 'fish',
    'milk': 'dairy',
    'cheese': 'dairy',
    'egg': 'dairy',
    'yogurt': 'dairy',
    'vegetable': 'vegetables',
    'carrot': 'vegetables',
    'apple': 'fruits',
    'banana': 'fruits',
    'rice': 'grains',
    'pasta': 'grains',
    'lentil': 'legumes',
    'chickpea': 'legumes',
    'almond': 'nuts',
    'walnut': 'nuts',
    'oil': 'fats',
    'butter': 'fats',
    'chocolate': 'sweets',
    'cookie': 'sweets',
    'tea': 'beverages',
    'coffee': 'beverages',
    'juice': 'beverages',
  };

  static final _meta = <String, Map<String, String>>{
    'meat': {'emoji': '🥩', 'name': 'Meat & Poultry'},
    'fish': {'emoji': '🐟', 'name': 'Fish & Seafood'},
    'dairy': {'emoji': '🥚', 'name': 'Dairy & Eggs'},
    'vegetables': {'emoji': '🥦', 'name': 'Vegetables'},
    'fruits': {'emoji': '🍎', 'name': 'Fruits'},
    'grains': {'emoji': '🌾', 'name': 'Grains & Cereals'},
    'legumes': {'emoji': '🫘', 'name': 'Legumes'},
    'nuts': {'emoji': '🥜', 'name': 'Nuts & Seeds'},
    'fats': {'emoji': '🧈', 'name': 'Fats & Oils'},
    'sweets': {'emoji': '🍫', 'name': 'Snacks & Sweets'},
    'beverages': {'emoji': '🥤', 'name': 'Beverages'},
  };

  static NutritionCategory mapToCategory(FoodItem item) {
    final name = item.name.toLowerCase();
    for (final kw in _keywords.keys) {
      if (name.contains(kw)) return _categoryForId(_keywords[kw]!);
    }
    final fallback = item.description.toLowerCase();
    for (final id in _meta.keys) {
      if (fallback.contains(id)) return _categoryForId(id);
    }
    return const NutritionCategory(
        id: 'other', emoji: '❓', name: 'Other', items: const [], imageUrl: '');
  }

  static NutritionCategory _categoryForId(String id) {
    final m = _meta[id]!;
    // Varsayılan imageUrl eşlemesi (id'ye göre)
    final imageMap = {
      'meat': 'assets/nutrition/image/meats and poultry.png',
      'fish': 'assets/nutrition/image/Fish and Seafood.jpg',
      'dairy': 'assets/nutrition/image/Diary and Eggs.jpg',
      'vegetables': 'assets/nutrition/image/vegetables.png',
      'fruits': 'assets/nutrition/image/fruits.png',
      'grains': 'assets/nutrition/image/grains and cerals.jpg',
      'legumes': 'assets/nutrition/image/legumes.jpg',
      'nuts': 'assets/nutrition/image/nuts and seeds.png',
      'fats': 'assets/nutrition/image/fats and oils.png',
      'sweets': 'assets/nutrition/image/snack and sweets.png',
      'beverages': 'assets/nutrition/image/Beverages.png',
    };
    return NutritionCategory(
        id: id,
        emoji: m['emoji']!,
        name: m['name']!,
        items: const [],
        imageUrl: imageMap[id] ?? '');
  }
}
