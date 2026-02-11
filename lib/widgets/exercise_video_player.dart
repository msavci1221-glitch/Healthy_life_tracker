import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ExerciseVideo extends StatefulWidget {
  final String url;
  const ExerciseVideo({super.key, required this.url});

  @override
  State<ExerciseVideo> createState() => _ExerciseVideoState();
}

class _ExerciseVideoState extends State<ExerciseVideo> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final u = widget.url.trim();
    if (u.isEmpty) return;

    VideoPlayerController c;
    // Asset mi network mü kontrol et
    if (u.startsWith('assets/')) {
      c = VideoPlayerController.asset(u);
    } else if (u.startsWith('http://') || u.startsWith('https://')) {
      c = VideoPlayerController.networkUrl(Uri.parse(u));
    } else {
      // Geçersiz format, hata göster
      _failed = true;
      if (mounted) setState(() {});
      return;
    }
    _controller = c;

    try {
      await c.initialize();
      await c.setLooping(true);
      await c.play();
    } catch (_) {
      _failed = true;
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;

    if (widget.url.trim().isEmpty) {
      return const Center(
        child: Text('No video', style: TextStyle(color: Colors.black54)),
      );
    }

    if (_failed) {
      return const Center(
        child: Text('Video failed', style: TextStyle(color: Colors.black54)),
      );
    }

    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: c.value.aspectRatio,
      child: VideoPlayer(c),
    );
  }
}
