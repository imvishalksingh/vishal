import 'dart:math';
import 'package:flutter/material.dart';

class TapSparkles extends StatefulWidget {
  final Widget child;

  const TapSparkles({super.key, required this.child});

  @override
  State<TapSparkles> createState() => _TapSparklesState();
}

class _TapSparklesState extends State<TapSparkles> with SingleTickerProviderStateMixin {
  final List<_Sparkle> _sparkles = [];
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..addListener(() {
        setState(() {});
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spawn(Offset pos) {
    final rng = Random();
    for (int i = 0; i < 8; i++) {
      _sparkles.add(_Sparkle(
        origin: pos,
        angle: rng.nextDouble() * 2 * pi,
        speed: 20 + rng.nextDouble() * 40,
        start: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => _spawn(event.localPosition),
      child: CustomPaint(
        painter: _SparklePainter(_sparkles),
        child: widget.child,
      ),
    );
  }
}

class _Sparkle {
  final Offset origin;
  final double angle;
  final double speed;
  final int start;

  _Sparkle({required this.origin, required this.angle, required this.speed, required this.start});
}

class _SparklePainter extends CustomPainter {
  final List<_Sparkle> sparkles;

  _SparklePainter(this.sparkles);

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now().millisecondsSinceEpoch;
    sparkles.removeWhere((s) => now - s.start > 700);

    for (final s in sparkles) {
      final t = (now - s.start) / 700.0;
      final dist = s.speed * t;
      final pos = Offset(
        s.origin.dx + cos(s.angle) * dist,
        s.origin.dy + sin(s.angle) * dist,
      );
      final paint = Paint()
        ..color = Colors.primaries[(s.start ~/ 50) % Colors.primaries.length].withOpacity(1 - t)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 3 + (1 - t) * 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => true;
}
