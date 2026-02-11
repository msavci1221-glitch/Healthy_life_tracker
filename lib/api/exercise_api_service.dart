import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ExerciseApiService {
  final http.Client _client;
  ExerciseApiService({http.Client? client}) : _client = client ?? http.Client();

  String get _host => (dotenv.env['EXERCISE_API_HOST'] ?? '').trim();
  String get _key => (dotenv.env['EXERCISE_API_KEY'] ?? '').trim();

  Map<String, String> get _headers => {
        'X-RapidAPI-Key': _key,
        'X-RapidAPI-Host': _host,
        'Accept': 'application/json',
      };

  Future<List<Map<String, dynamic>>> fetchByBodyPart({
    required String bodyPart,
    int limit = 30,
    int offset = 0,
  }) async {
    if (_host.isEmpty || _key.isEmpty) {
      throw Exception('Missing EXERCISE_API_HOST or EXERCISE_API_KEY in .env');
    }

    // ExerciseDB genelde bodyPart değerlerini küçük harf ister:
    // chest, back, upper legs, waist vs
    final uri = Uri.https(_host, '/exercises/bodyPart/$bodyPart', {
      'limit': '$limit',
      'offset': '$offset',
    });

    final res = await _client.get(uri, headers: _headers);

    debugPrint('API GET $uri -> ${res.statusCode}');
    if (res.statusCode != 200) {
      final body =
          res.body.length > 250 ? res.body.substring(0, 250) : res.body;
      debugPrint('API ERROR BODY: $body');
      throw Exception('API error: ${res.statusCode}');
    }

    final data = jsonDecode(res.body);
    if (data is! List) {
      throw Exception('Unexpected response: not a list');
    }

    return data
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }
}
