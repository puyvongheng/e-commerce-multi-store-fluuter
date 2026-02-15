import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/environment.dart';

class EnvironmentPainter extends CustomPainter {
  final List<WaterBubble> bubbles;
  final List<UnderwaterRock> rocks;
  final List<Seaweed> seaweeds;
  final List<LightRay> lightRays;
  final Whirlpool? whirlpool;
  final bool isNightMode;

  EnvironmentPainter({
    required this.bubbles,
    required this.rocks,
    required this.seaweeds,
    required this.lightRays,
    this.whirlpool,
    this.isNightMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw light rays first (background)
    _drawLightRays(canvas, size);

    // Draw seaweed
    _drawSeaweed(canvas, size);

    // Draw rocks
    _drawRocks(canvas, size);

    // Draw whirlpool
    if (whirlpool != null && whirlpool!.isActive()) {
      _drawWhirlpool(canvas, size);
    }

    // Draw bubbles (foreground)
    _drawBubbles(canvas, size);
  }

  void _drawLightRays(Canvas canvas, Size size) {
    for (final ray in lightRays) {
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(ray.getCurrentOpacity()),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(ray.x, 0, ray.width, size.height));

      final path = Path();
      path.moveTo(ray.x, 0);
      path.lineTo(ray.x + ray.width * 0.2, size.height);
      path.lineTo(ray.x + ray.width * 0.8, size.height);
      path.lineTo(ray.x + ray.width, 0);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  void _drawBubbles(Canvas canvas, Size size) {
    for (final bubble in bubbles) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(bubble.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(
        Offset(bubble.x, bubble.y),
        bubble.size / 2,
        paint,
      );

      // Highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(bubble.opacity * 0.5);

      canvas.drawCircle(
        Offset(bubble.x - bubble.size * 0.2, bubble.y - bubble.size * 0.2),
        bubble.size * 0.15,
        highlightPaint,
      );
    }
  }

  void _drawRocks(Canvas canvas, Size size) {
    // Rocks are drawn as emoji in the main widget
    // This could draw shadows or outlines
  }

  void _drawSeaweed(Canvas canvas, Size size) {
    for (final seaweed in seaweeds) {
      final paint = Paint()
        ..color = seaweed.isHit
            ? Colors.lightGreen.withOpacity(0.6)
            : Colors.green.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(seaweed.x, seaweed.y);

      // Create wavy seaweed
      final segments = 10;
      for (int i = 0; i <= segments; i++) {
        final t = i / segments;
        final y = seaweed.y - (seaweed.height * t);
        final sway = math.sin(seaweed.swayAngle + t * math.pi * 2) * 15;
        path.lineTo(seaweed.x + sway, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawWhirlpool(Canvas canvas, Size size) {
    final whirlpool = this.whirlpool!;

    // Draw spiral
    for (int ring = 0; ring < 5; ring++) {
      final paint = Paint()
        ..color = Colors.cyan.withOpacity(0.3 - ring * 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      final radius = whirlpool.radius * (1 - ring * 0.15);

      final path = Path();
      for (double angle = 0; angle < math.pi * 2; angle += 0.1) {
        final adjustedAngle = angle + whirlpool.rotationAngle + ring * 0.5;
        final r = radius * (1 - angle / (math.pi * 2) * 0.2);
        final x = whirlpool.x + math.cos(adjustedAngle) * r;
        final y = whirlpool.y + math.sin(adjustedAngle) * r;

        if (angle == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(EnvironmentPainter oldDelegate) => true;
}
