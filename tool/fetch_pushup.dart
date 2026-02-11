import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final root = Directory.current.path;
  final envFile = File('$root/.env');
  if (!envFile.existsSync()) {
    print(
        'No .env file found at project root. Put RapidAPI keys in .env and retry.');
    return;
  }
  final envLines = envFile.readAsLinesSync();
  final env = <String, String>{};
  for (final line in envLines) {
    final l = line.trim();
    if (l.isEmpty || l.startsWith('#')) continue;
    final idx = l.indexOf('=');
    if (idx <= 0) continue;
    final k = l.substring(0, idx).trim();
    final v = l.substring(idx + 1).trim();
    env[k] = v;
  }

  final baseUrl = env['EXERCISE_BASE_URL'];
  final apiKey = env['EXERCISE_API_KEY'];
  final apiHost = env['EXERCISE_API_HOST'];
  if (baseUrl == null || apiKey == null || apiHost == null) {
    print(
        'Missing EXERCISE_BASE_URL, EXERCISE_API_KEY, or EXERCISE_API_HOST in .env');
    return;
  }

  final remoteId = 'exr_41n2hNXJadYcfjnd';
  final uri =
      Uri.parse(baseUrl + '/api/v1/exercises/' + Uri.encodeComponent(remoteId));

  final headers = {
    'x-rapidapi-key': apiKey,
    'x-rapidapi-host': apiHost,
    'Accept': 'application/json',
  };

  try {
    print('GET $uri');
    final resp =
        await http.get(uri, headers: headers).timeout(Duration(seconds: 15));
    print('Status: ${resp.statusCode}');
    if (resp.statusCode == 200) {
      final body = json.decode(resp.body);
      final pretty = const JsonEncoder.withIndent('  ').convert(body);
      print(pretty);
    } else {
      print('Body: ${resp.body}');
    }
  } catch (e) {
    print('Error fetching detail: $e');
  }
}
