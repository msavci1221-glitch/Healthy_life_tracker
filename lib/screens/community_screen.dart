import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'add_post_screen.dart';
import 'post_detail_screen.dart';

String get currentUserId => FirebaseAuth.instance.currentUser!.uid;

/// 🔒 base64 güvenli decode
Uint8List? safeBase64(dynamic value) {
  try {
    if (value is! String || value.isEmpty) return null;
    return base64Decode(value);
  } catch (_) {
    return null;
  }
}

/// ⏱️ zaman formatlama (NULL SAFE)
String formatTime(Timestamp? ts) {
  if (ts == null) return 'just now';

  final diff = DateTime.now().difference(ts.toDate());

  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hours ago';
  return '${diff.inDays} days ago';
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Community',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPostScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Post'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final imageBytes = safeBase64(data['imageBase64']);
              if (imageBytes == null) return const SizedBox();

              final likes = List<String>.from(data['likes'] ?? []);
              final liked = likes.contains(currentUserId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 14,
                        color: Colors.black.withOpacity(0.06),
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 👤 HEADER
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 8, 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue[400],
                              child: Text(
                                (data['userName'] ?? '').isNotEmpty
                                    ? data['userName'][0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['userName'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formatTime(data['createdAt'] as Timestamp?),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (data['userId'] == currentUserId)
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                onPressed: () => doc.reference.delete(),
                              ),
                          ],
                        ),
                      ),

                      /// 📸 IMAGE
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailScreen(postId: doc.id),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.memory(
                            imageBytes,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      /// ❤️ 💬 LIKE + COMMENT BAR
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                liked ? Icons.favorite : Icons.favorite_border,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                doc.reference.update({
                                  'likes': liked
                                      ? FieldValue.arrayRemove([currentUserId])
                                      : FieldValue.arrayUnion([currentUserId]),
                                });
                              },
                            ),
                            Text(
                              '${likes.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 20,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 6),
                            StreamBuilder<QuerySnapshot>(
                              stream: doc.reference
                                  .collection('comments')
                                  .snapshots(),
                              builder: (context, snap) {
                                final count =
                                    snap.hasData ? snap.data!.docs.length : 0;
                                return Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
