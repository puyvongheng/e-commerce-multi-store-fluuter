import 'fish.dart';

class BossFish extends Fish {
  final String name;
  bool isEnraged = false;
  double rageThreshold = 0.3; // Enrage at 30% HP

  BossFish({
    required super.x,
    required super.y,
    required this.name,
    required super.emoji,
    required super.hp,
    required super.maxHp,
    required super.coins,
    required super.speed,
    required super.size,
  });

  @override
  void update() {
    super.update();

    // Check if should enrage
    if (!isEnraged && hpPercentage <= rageThreshold) {
      isEnraged = true;
      speed *= 1.5; // Move faster when enraged
    }
  }

  // Boss-specific factory
  factory BossFish.spawn(
      double screenWidth, double screenHeight, int playerLevel) {
    final bosses = [
      {'emoji': '🦈', 'name': 'Mega Shark'},
      {'emoji': '🐋', 'name': 'Blue Whale'},
      {'emoji': '🦑', 'name': 'Kraken'},
      {'emoji': '🐙', 'name': 'Giant Octopus'},
    ];

    final boss = bosses[playerLevel % bosses.length];
    final baseHp = 50 + (playerLevel * 10);
    final baseCoins = 500 + (playerLevel * 50);

    return BossFish(
      x: screenWidth + 100,
      y: screenHeight / 2,
      name: boss['name'] as String,
      emoji: boss['emoji'] as String,
      hp: baseHp,
      maxHp: baseHp,
      coins: baseCoins,
      speed: -0.8,
      size: 120,
    );
  }
}
