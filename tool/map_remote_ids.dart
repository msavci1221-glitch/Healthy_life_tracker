import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

String _normalize(String s) =>
    s.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), '');

// ignore: unused_element
Future<Map<String, String>> _fetchRemoteLookup(
    String baseUrl, String apiKey, String apiHost) async {
  // Not used: kept for compatibility
  return {};
}

void main(List<String> args) async {
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

  print('Preparing to map remote IDs using search endpoint...');

  final dataFile = File('$root/lib/data/workout_data.dart');
  if (!dataFile.existsSync()) {
    print('Cannot find lib/data/workout_data.dart');
    return;
  }
  var content = dataFile.readAsStringSync();

  final itemRegex =
      RegExp(r"(const\s+)?ExerciseItem\(([\s\S]*?)\)", multiLine: true);
  final idRegex = RegExp(r"id:\s*'([^']+)'", multiLine: true);
  final nameRegex = RegExp(r"name:\s*'([^']+)'", multiLine: true);

  var matched = 0;
  var unmatched = <String>[];
  final newContent = StringBuffer();
  var last = 0;

  for (final m in itemRegex.allMatches(content)) {
    newContent.write(content.substring(last, m.start));
    final full = m.group(0)!;
    final params = m.group(2)!;
    final idMatch = idRegex.firstMatch(params);
    final nameMatch = nameRegex.firstMatch(params);
    String localId = idMatch?.group(1) ?? '';
    String localName = nameMatch?.group(1) ?? '';

    String? remoteId;
    // Try search by name first (throttle to avoid rate limits)
    if (localName.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 150));
      try {
        final headers = {
          'x-rapidapi-key': apiKey,
          'x-rapidapi-host': apiHost,
          'Accept': 'application/json',
        };
        final q = Uri.encodeQueryComponent(localName);
        final uri = Uri.parse(baseUrl + '/api/v1/exercises/search?search=$q');
        final resp = await http.get(uri, headers: headers);
        if (resp.statusCode == 200) {
          final body = json.decode(resp.body);
          List data = [];
          if (body is Map && body['success'] == true && body['data'] is List) {
            data = body['data'];
          } else if (body is List) {
            data = body;
          }
          final key = _normalize(localName);
          for (final e in data) {
            if (e is Map) {
              final rname =
                  (e['name'] ?? e['exerciseName'] ?? '')?.toString() ?? '';
              if (_normalize(rname) == key) {
                remoteId = (e['exerciseId'] ?? e['id'] ?? e['exercise_id'])
                    ?.toString();
                break;
              }
            }
          }
          if (remoteId == null && data.isNotEmpty) {
            final e = data.first as Map;
            remoteId =
                (e['exerciseId'] ?? e['id'] ?? e['exercise_id'])?.toString();
          }
        } else {
          print('search failed for $localName: ${resp.statusCode}');
        }
      } catch (e) {
        print('search error for $localName: $e');
      }
    }
    // If still null, fallback to searching by id slug
    if (remoteId == null && localId.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        final headers = {
          'x-rapidapi-key': apiKey,
          'x-rapidapi-host': apiHost,
          'Accept': 'application/json',
        };
        final q = Uri.encodeQueryComponent(localId);
        final uri = Uri.parse(baseUrl + '/api/v1/exercises/search?search=$q');
        final resp = await http.get(uri, headers: headers);
        if (resp.statusCode == 200) {
          final body = json.decode(resp.body);
          List data = [];
          if (body is Map && body['success'] == true && body['data'] is List) {
            data = body['data'];
          } else if (body is List) {
            data = body;
          }
          if (data.isNotEmpty) {
            final e = data.first as Map;
            remoteId =
                (e['exerciseId'] ?? e['id'] ?? e['exercise_id'])?.toString();
          }
        }
      } catch (_) {}
    }

    if (remoteId != null) {
      matched++;
      // replace existing remoteId or insert after name
      if (params.contains('remoteId')) {
        final replacedParams = params.replaceAll(
            RegExp(r"remoteId:\s*[^,\n]*,?"), "remoteId: '$remoteId',");
        final replaced = full.replaceFirst(params, replacedParams);
        newContent.write(replaced);
      } else {
        final nameLoc = nameRegex.firstMatch(params);
        if (nameLoc != null) {
          final beforeName = params.substring(0, nameLoc.end);
          final afterName = params.substring(nameLoc.end);
          final injected = "${beforeName} remoteId: '$remoteId',$afterName";
          final replaced = full.replaceFirst(params, injected);
          newContent.write(replaced);
        } else {
          newContent.write(full);
        }
      }
    } else {
      unmatched.add('$localId - $localName');
      // ensure remoteId: null is present with TODO (replace if exists)
      if (params.contains('remoteId')) {
        final replacedParams = params.replaceAll(
            RegExp(r"remoteId:\s*[^,\n]*,?"),
            "remoteId: null, // TODO: map remoteId\n");
        final replaced = full.replaceFirst(params, replacedParams);
        newContent.write(replaced);
      } else {
        final nameLoc = nameRegex.firstMatch(params);
        if (nameLoc != null) {
          final beforeName = params.substring(0, nameLoc.end);
          final afterName = params.substring(nameLoc.end);
          final injected =
              "${beforeName} remoteId: null, // TODO: map remoteId\n$afterName";
          final replaced = full.replaceFirst(params, injected);
          newContent.write(replaced);
        } else {
          newContent.write(full);
        }
      }
    }

    last = m.end;
  }
  newContent.write(content.substring(last));

  final backup = File('$root/lib/data/workout_data.dart.bak');
  backup.writeAsStringSync(content);
  dataFile.writeAsStringSync(newContent.toString());

  print('Total exercises processed: ${matched + unmatched.length}');
  print('Matched: $matched');
  print('Unmatched: ${unmatched.length}');
  if (unmatched.isNotEmpty) {
    print('Unmatched items (localId - name):');
    for (final u in unmatched) print(' - $u');
  }
  print('Backup written to lib/data/workout_data.dart.bak');
  print('Done. Review changes and run your app.');
}
