import 'package:flutter/material.dart';
import 'dart:math' as math;

class Bullet {
  double x;
  double y;
  double angle;
  double speed;
  Color color;
  String emoji;
  double size;
  int lifetime = 0;
  bool isCritical = false;
  bool isRainbow = false;
  List<Color> rainbowColors = [];

  Bullet({
    required this.x,
    required this.y,
    required this.angle,
    required this.speed,
    required this.color,
    required this.emoji,
    required this.size,
    this.isCritical = false,
    this.isRainbow = false,
  }) {
    if (isRainbow) {
      rainbowColors = [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.indigo,
        Colors.purple,
      ];
    }
  }

  void update({String weather = 'clear'}) {
    // Apply weather effects
    double speedModifier = 1.0;
    double angleModifier = 0.0;

    switch (weather) {
      case 'rain':
        speedModifier = 0.8;
        break;
      case 'storm':
        angleModifier = math.sin(lifetime * 0.1) * 0.05;
        break;
      case 'wind':
        angleModifier = 0.02;
        break;
    }

    x += math.cos(angle + angleModifier) * speed * speedModifier;
    y += math.sin(angle + angleModifier) * speed * speedModifier;
    lifetime++;
  }

  bool isOffScreen(double screenWidth, double screenHeight) {
    return x < -50 ||
        x > screenWidth + 50 ||
        y < -50 ||
        y > screenHeight + 50 ||
        lifetime > 200;
  }

  Color getCurrentColor() {
    if (isRainbow && rainbowColors.isNotEmpty) {
      final index = (lifetime ~/ 5) % rainbowColors.length;
      return rainbowColors[index];
    }
    return color;
  }
}
