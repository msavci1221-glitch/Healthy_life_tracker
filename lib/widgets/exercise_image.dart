import 'package:flutter/material.dart';

class ExerciseImage extends StatefulWidget {
  final String url;
  final BoxFit fit;

  const ExerciseImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
  });

  @override
  State<ExerciseImage> createState() => _ExerciseImageState();
}

class _ExerciseImageState extends State<ExerciseImage> {
  late String _tryUrl;
  bool _triedSwap = false;

  @override
  void initState() {
    super.initState();
    _tryUrl = widget.url.trim();
  }

  @override
  void didUpdateWidget(covariant ExerciseImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _tryUrl = widget.url.trim();
      _triedSwap = false;
    }
  }

  String _swapExt(String u) {
    final lower = u.toLowerCase();
    if (lower.endsWith('.png')) return u.substring(0, u.length - 4) + '.jpg';
    if (lower.endsWith('.jpg')) return u.substring(0, u.length - 4) + '.png';
    if (lower.endsWith('.jpeg')) return u.substring(0, u.length - 5) + '.png';
    return u;
  }

  @override
  Widget build(BuildContext context) {
    if (_tryUrl.isEmpty) return const Icon(Icons.image_not_supported);

    return Image.network(
      _tryUrl,
      fit: widget.fit,
      errorBuilder: (_, __, ___) {
        // 1 defa uzantıyı değiştirip tekrar dene
        if (!_triedSwap) {
          _triedSwap = true;
          final swapped = _swapExt(_tryUrl);

          if (swapped != _tryUrl) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _tryUrl = swapped);
            });
            return const Center(child: CircularProgressIndicator());
          }
        }
        return const Icon(Icons.image_not_supported);
      },
      loadingBuilder: (ctx, child, p) {
        if (p == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
