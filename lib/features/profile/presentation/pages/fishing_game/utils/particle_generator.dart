import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/particle.dart';

class ParticleGenerator {
  static final _random = math.Random();

  static List<Particle> createHitParticles(double x, double y, bool isFatal) {
    final particles = <Particle>[];
    final count = isFatal ? 15 : 5;

    for (int i = 0; i < count; i++) {
      particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 8,
        vy: (_random.nextDouble() - 0.5) * 8,
        color: isFatal ? Colors.amber : Colors.white,
        size: _random.nextDouble() * 8 + 4,
        lifetime: 30,
        opacity: 1.0,
        type: ParticleType.hit,
      ));
    }

    return particles;
  }

  static List<Particle> createCoinParticles(double x, double y) {
    final particles = <Particle>[];

    for (int i = 0; i < 10; i++) {
      particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 6,
        vy: -_random.nextDouble() * 8 - 2,
        color: Colors.amber,
        size: 12,
        lifetime: 40,
        opacity: 1.0,
        emoji: '🪙',
        type: ParticleType.coin,
      ));
    }

    return particles;
  }

  static List<Particle> createMuzzleFlash(
      double x, double y, double angle, Color color) {
    final particles = <Particle>[];

    for (int i = 0; i < 8; i++) {
      particles.add(Particle(
        x: x,
        y: y,
        vx: math.cos(angle + (_random.nextDouble() - 0.5) * 0.5) * 5,
        vy: math.sin(angle + (_random.nextDouble() - 0.5) * 0.5) * 5,
        color: color,
        size: _random.nextDouble() * 6 + 3,
        lifetime: 15,
        opacity: 1.0,
        type: ParticleType.muzzleFlash,
      ));
    }

    return particles;
  }

  static List<Particle> createExplosion(double x, double y, {int count = 50}) {
    final particles = <Particle>[];

    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = _random.nextDouble() * 15 + 5;

      particles.add(Particle(
        x: x,
        y: y,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        color: [Colors.orange, Colors.red, Colors.yellow][i % 3],
        size: _random.nextDouble() * 12 + 6,
        lifetime: 50,
        opacity: 1.0,
        type: ParticleType.explosion,
      ));
    }

    return particles;
  }

  static List<Particle> createLightningArc(
      double x1, double y1, double x2, double y2) {
    final particles = <Particle>[];
    final steps = 10;

    for (int i = 0; i < steps; i++) {
      final t = i / steps;
      final x = x1 + (x2 - x1) * t + (_random.nextDouble() - 0.5) * 20;
      final y = y1 + (y2 - y1) * t + (_random.nextDouble() - 0.5) * 20;

      particles.add(Particle(
        x: x,
        y: y,
        vx: 0,
        vy: 0,
        color: Colors.cyan,
        size: 8,
        lifetime: 10,
        opacity: 1.0,
        type: ParticleType.lightning,
      ));
    }

    return particles;
  }

  static List<Particle> createWeatherParticles(
      String weather, double screenWidth, double screenHeight) {
    final particles = <Particle>[];

    switch (weather) {
      case 'rain':
        for (int i = 0; i < 20; i++) {
          particles.add(Particle(
            x: _random.nextDouble() * screenWidth,
            y: -10,
            vx: 0,
            vy: 10,
            color: Colors.blue.withOpacity(0.3),
            size: 2,
            lifetime: 100,
            opacity: 0.5,
            type: ParticleType.weather,
          ));
        }
        break;

      case 'storm':
        for (int i = 0; i < 30; i++) {
          particles.add(Particle(
            x: _random.nextDouble() * screenWidth,
            y: -10,
            vx: _random.nextDouble() * 4 - 2,
            vy: 15,
            color: Colors.blue.withOpacity(0.4),
            size: 3,
            lifetime: 80,
            opacity: 0.6,
            type: ParticleType.weather,
          ));
        }
        break;
    }

    return particles;
  }

  static List<Particle> createNuclearExplosion(
      double screenWidth, double screenHeight) {
    final particles = <Particle>[];
    final centerX = screenWidth / 2;
    final centerY = screenHeight / 2;

    // Main explosion
    particles.addAll(createExplosion(centerX, centerY, count: 200));

    // Shockwave rings
    for (int ring = 0; ring < 5; ring++) {
      for (int i = 0; i < 20; i++) {
        final angle = (i / 20) * math.pi * 2;
        final radius = 50.0 + (ring * 100);

        particles.add(Particle(
          x: centerX + math.cos(angle) * radius,
          y: centerY + math.sin(angle) * radius,
          vx: math.cos(angle) * 10,
          vy: math.sin(angle) * 10,
          color: Colors.white,
          size: 15,
          lifetime: 60 - (ring * 10),
          opacity: 1.0,
          type: ParticleType.explosion,
        ));
      }
    }

    return particles;
  }
}
