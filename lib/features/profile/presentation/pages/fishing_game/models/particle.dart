import 'package:flutter/material.dart';

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  int lifetime;
  double opacity;
  String? emoji;
  final ParticleType type;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.lifetime,
    required this.opacity,
    this.emoji,
    this.type = ParticleType.normal,
  });

  void update() {
    x += vx;
    y += vy;
    vy += 0.3; // Gravity
    lifetime--;
    opacity -= 0.02;
  }

  bool isAlive() => lifetime > 0 && opacity > 0;
}

enum ParticleType {
  normal,
  muzzleFlash,
  hit,
  coin,
  explosion,
  lightning,
  weather,
}
