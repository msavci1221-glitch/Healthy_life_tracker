import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;

Future<String?> compressToBase64(File file) async {
  final bytes = await file.readAsBytes();
  final image = img.decodeImage(bytes);
  if (image == null) return null;

  // 🔽 TELEFON FOTOĞRAFI KÜÇÜLTÜLÜYOR
  final resized = img.copyResize(image, width: 600);

  // 🔽 QUALITY DÜŞÜR
  final jpg = img.encodeJpg(resized, quality: 70);

  return base64Encode(jpg);
}
