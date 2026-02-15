import 'package:flutter/material.dart';

class Fish {
  double x;
  double y;
  String emoji;
  int hp;
  int maxHp;
  int coins;
  double speed;
  double size;
  double animationTime = 0;
  bool isFrozen = false;

  Fish({
    required this.x,
    required this.y,
    required this.emoji,
    required this.hp,
    required this.maxHp,
    required this.coins,
    required this.speed,
    required this.size,
  });

  void update() {
    if (!isFrozen) {
      x += speed;
    }
    animationTime += 0.05;
  }

  bool isOffScreen(double screenWidth) {
    return x < -100 || x > screenWidth + 100;
  }

  void takeDamage(int damage) {
    hp -= damage;
  }

  bool isDead() => hp <= 0;

  double get hpPercentage => hp / maxHp;
}
