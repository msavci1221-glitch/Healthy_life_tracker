import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../data/nutrition_data.dart'; // FoodNutrients için

class SpoonacularService {
  static const String _baseUrl = 'https://api.spoonacular.com';
  final String _apiKey;

  SpoonacularService._(this._apiKey);

  factory SpoonacularService.fromEnv() {
    final key = dotenv.env['SPOONACULAR_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('SPOONACULAR_API_KEY .env içinde yok veya boş.');
    }
    return SpoonacularService._(key);
  }

  /// GET /food/ingredients/search
  Future<List<dynamic>> searchIngredient(String query) async {
    final uri = Uri.parse('$_baseUrl/food/ingredients/search').replace(
      queryParameters: {
        'apiKey': _apiKey,
        'query': query,
        'number': '10',
      },
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception(
          'Ingredient search failed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['results'] as List<dynamic>? ?? <dynamic>[]);
  }

  /// ✅ DOĞRU Parse/Nutrition endpoint:
  /// POST /recipes/parseIngredients?includeNutrition=true
  ///
  /// Bu method geri dönüşü senin mevcut nutrientsFromParseResponse() fonksiyonuna
  /// uyacak şekilde {"parsed": <List>} formatına çevirir.
  Future<Map<String, dynamic>> parseNutrition(String text) async {
    final uri = Uri.parse('$_baseUrl/recipes/parseIngredients').replace(
      queryParameters: {
        'apiKey': _apiKey,
        'includeNutrition': 'true',
      },
    );

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'ingredientList': text},
    );

    if (res.statusCode != 200) {
      // 429 gibi durumlarda body çok uzun olabilir, ama hata ayıklamak için kalsın
      throw Exception('Nutrition parse failed: ${res.statusCode} ${res.body}');
    }

    // parseIngredients endpoint'i genelde List döndürür.
    final decoded = jsonDecode(res.body);

    // Bizim nutrientsFromParseResponse() "json['parsed'] as List" bekliyor.
    // O yüzden burada "parsed" anahtarı içine koyuyoruz.
    if (decoded is List) {
      return {'parsed': decoded};
    }

    // Çok nadir Map dönerse de yine uyumlu hale getirelim:
    if (decoded is Map<String, dynamic>) {
      // Eğer zaten parsed varsa direkt döndür
      if (decoded.containsKey('parsed') && decoded['parsed'] is List)
        return decoded;
      // Yoksa tek elemanlı liste yap
      return {
        'parsed': [decoded]
      };
    }

    // Beklenmeyen format
    return {'parsed': []};
  }

  String ingredientImageUrl(String imageName) {
    return 'https://spoonacular.com/cdn/ingredients_250x250/$imageName';
  }

  static FoodNutrients nutrientsFromParseResponse(Map<String, dynamic> json) {
    final parsed = (json['parsed'] as List?) ?? const [];
    if (parsed.isEmpty) return const FoodNutrients();

    final p0 = parsed.first;
    if (p0 is! Map) return const FoodNutrients();

    final nutrition = p0['nutrition'];
    if (nutrition is! Map) return const FoodNutrients();

    final nutrients = (nutrition['nutrients'] as List?) ?? const [];

    double pick(String name) {
      for (final n in nutrients) {
        if (n is Map && n['name'] == name) {
          final v = n['amount'];
          if (v is num) return v.toDouble();
        }
      }
      return 0.0;
    }

    return FoodNutrients(
      caloriesKcal: pick('Calories'),
      proteinG: pick('Protein'),
      carbsG: pick('Carbohydrates'),
      fatG: pick('Fat'),
    );
  }
}
