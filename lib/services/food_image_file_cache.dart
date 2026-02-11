import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FoodImageFileCache {
  static bool isRemoteUrl(String s) =>
      s.startsWith('http://') || s.startsWith('https://');

  /// Her zaman aynı yere kaydediyoruz:
  /// .../food_images/{foodId}.jpg
  static Future<String> localPathFor(String foodId) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/food_images/$foodId.jpg';
  }

  /// Dosya varsa path döner, yoksa null
  static Future<String?> existingLocalPath(String foodId) async {
    final p = await localPathFor(foodId);
    final f = File(p);
    return await f.exists() ? p : null;
  }

  /// remoteUrl'deki resmi indirir ve kalıcı dosyaya yazar.
  /// Aynı foodId için her zaman aynı dosyaya yazar.
  static Future<String?> downloadToLocalFile({
    required String foodId,
    required String remoteUrl,
  }) async {
    if (remoteUrl.isEmpty) return null;

    try {
      final res = await http.get(Uri.parse(remoteUrl));
      if (res.statusCode != 200) return null;

      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/food_images');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final file = File('${folder.path}/$foodId.jpg');
      await file.writeAsBytes(res.bodyBytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }
}
