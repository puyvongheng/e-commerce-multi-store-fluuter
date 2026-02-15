import 'package:flutter/material.dart';

class PowerUp {
  double x;
  double y;
  String type;
  String emoji;
  Color color;
  double animationTime = 0;
  final String name;
  final String description;

  PowerUp({
    required this.x,
    required this.y,
    required this.type,
    required this.emoji,
    required this.color,
    required this.name,
    required this.description,
  });

  void update() {
    y += 1; // Fall down
    animationTime += 0.1;
  }

  bool isOffScreen(double screenHeight) => y > screenHeight;

  static PowerUp createRandom(double x, double y) {
    final powers = [
      {
        'type': 'rapid',
        'emoji': '⚡',
        'color': Colors.yellow,
        'name': 'បាញ់លឿន',
        'description': '+3 bullets'
      },
      {
        'type': 'mega',
        'emoji': '💪',
        'color': Colors.red,
        'name': 'កម្លាំងធំ',
        'description': '5x damage'
      },
      {
        'type': 'lightning',
        'emoji': '🌩️',
        'color': Colors.cyan,
        'name': 'ផ្លេកបន្ទោរ',
        'description': '+5 bullets + 2x damage'
      },
      {
        'type': 'freeze',
        'emoji': '❄️',
        'color': Colors.blue,
        'name': 'បង្កក',
        'description': 'Freeze all fish'
      },
    ];

    final power = (powers..shuffle()).first;

    return PowerUp(
      x: x,
      y: y,
      type: power['type'] as String,
      emoji: power['emoji'] as String,
      color: power['color'] as Color,
      name: power['name'] as String,
      description: power['description'] as String,
    );
  }
}
