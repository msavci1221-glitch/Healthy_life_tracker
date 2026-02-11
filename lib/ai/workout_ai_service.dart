import 'dart:convert';
import 'package:http/http.dart' as http;

import 'workout_plan_models.dart';

class WorkoutAIService {
  final String baseUrl;
  const WorkoutAIService({required this.baseUrl});

  Future<DraftPlanResponse> generateDraft({
    required WorkoutPlanRequest request,
  }) async {
    final uri = Uri.parse('$baseUrl/api/workout_plan');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception('AI service failed: ${res.statusCode} ${res.body}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return DraftPlanResponse.fromJson(json);
  }
}
