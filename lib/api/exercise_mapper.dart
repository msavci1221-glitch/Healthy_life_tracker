import '../data/workout_data.dart';

class ExerciseMapper {
  static ExerciseItem fromApi(Map<String, dynamic> j) {
    String s(dynamic v) => (v ?? '').toString().trim();

    final remoteId = s(j['id']);
    final name = s(j['name']);

    // API alanı hâlâ gifUrl diye geliyor (mp4)
    final videoUrl = s(j['gifUrl']);

    final bodyPartRaw = s(j['bodyPart']);
    final equipmentRaw = s(j['equipment']);

    // instructions bazen liste gelir
    final instructions = <String>[];
    final insRaw = j['instructions'];
    if (insRaw is List) {
      for (final x in insRaw) {
        final t = s(x);
        if (t.isNotEmpty) instructions.add(t);
      }
    }

    // id kesin String olmalı
    final safeId = remoteId.isNotEmpty
        ? remoteId
        : (name.isNotEmpty
            ? name
            : DateTime.now().millisecondsSinceEpoch.toString());

    // mp4 ise image göstermiyoruz
    final isVideo = videoUrl.toLowerCase().endsWith('.mp4');
    final imageUrl = isVideo ? '' : videoUrl;

    return ExerciseItem(
      id: safeId,
      remoteId: remoteId.isNotEmpty ? remoteId : '',

      name: name.isNotEmpty ? name : 'Unknown',
      description: '',

      // ✅ String (null değil)
      imageUrl: imageUrl,

      // ✅ sen ekledin
      videoUrl: videoUrl,

      // ✅ sende olan alanlar
      bodyPart: bodyPartRaw.isNotEmpty ? bodyPartRaw.toUpperCase() : '',
      equipment: equipmentRaw.isNotEmpty ? equipmentRaw.toUpperCase() : '',

      // ✅ required oldukları için boş liste veriyoruz
      instructions: instructions,
      tips: const [],
      variations: const [],

      met: 0.0,
    );
  }
}
