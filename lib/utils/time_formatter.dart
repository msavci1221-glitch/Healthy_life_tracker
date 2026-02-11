import 'package:cloud_firestore/cloud_firestore.dart';

String formatTime(Timestamp? timestamp) {
  if (timestamp == null) return '';

  final date = timestamp.toDate();
  final diff = DateTime.now().difference(date);

  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';

  return '${date.day}/${date.month}/${date.year}';
}
