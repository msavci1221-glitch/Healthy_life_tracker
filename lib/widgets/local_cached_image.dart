import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LocalCachedImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final Widget? errorWidget;
  final double? width;
  final double? height;

  const LocalCachedImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.width,
    this.height,
  });

  bool _isRemoteUrl(String s) {
    final u = s.toLowerCase();
    return u.startsWith('http://') || u.startsWith('https://');
  }

  bool _isVideoUrl(String s) {
    final u = s.toLowerCase();
    return u.endsWith('.mp4') || u.endsWith('.mov') || u.endsWith('.mkv');
  }

  bool _isGifUrl(String s) {
    final u = s.toLowerCase();
    return u.endsWith('.gif');
  }

  Widget _fallback() {
    return errorWidget ??
        const Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.black54,
            size: 36,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final s = url.trim();
    if (s.isEmpty) return _fallback();

    // VIDEO gelirse burada göstermiyoruz (ileride ayrı widget)
    if (_isVideoUrl(s)) return _fallback();

    // -----------------------------
    // LOCAL FILE (aynen korunuyor)
    // -----------------------------
    if (!_isRemoteUrl(s)) {
      final f = File(s);
      if (!f.existsSync()) return _fallback();
      return Image.file(
        f,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    // -----------------------------------------
    // REMOTE IMAGE / GIF (CACHE’Lİ)
    // -----------------------------------------
    return CachedNetworkImage(
      imageUrl: s,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 150),
      fadeOutDuration: const Duration(milliseconds: 150),
      placeholder: (context, _) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      errorWidget: (context, _, __) => _fallback(),
    );
  }
}
