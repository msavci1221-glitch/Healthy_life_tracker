class GeminiMealResult {
  final String foodName;
  final double calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  const GeminiMealResult({
    required this.foodName,
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  factory GeminiMealResult.fromJson(Map<String, dynamic> json) {
    return GeminiMealResult(
      foodName: json['foodName'] ?? 'Unknown Food',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
    );
  }
}
