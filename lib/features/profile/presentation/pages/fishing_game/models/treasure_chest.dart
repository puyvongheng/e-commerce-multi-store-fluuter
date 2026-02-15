import 'dart:math' as math;

class TreasureChest {
  double x;
  double y;
  int coinValue;
  bool isOpened = false;
  double animationTime = 0;
  final ChestType type;

  TreasureChest({
    required this.x,
    required this.y,
    required this.coinValue,
    required this.type,
  });

  void update() {
    y += 0.5; // Slow fall
    animationTime += 0.05;
  }

  bool isOffScreen(double screenHeight) => y > screenHeight;

  String get emoji {
    switch (type) {
      case ChestType.wooden:
        return '📦';
      case ChestType.silver:
        return '🎁';
      case ChestType.golden:
        return '💎';
    }
  }

  static TreasureChest createRandom(double x, double y, int playerLevel) {
    final random = math.Random();
    final roll = random.nextDouble();

    ChestType type;
    int baseValue;

    if (roll < 0.6) {
      type = ChestType.wooden;
      baseValue = 100;
    } else if (roll < 0.9) {
      type = ChestType.silver;
      baseValue = 250;
    } else {
      type = ChestType.golden;
      baseValue = 500;
    }

    final coinValue = baseValue + (playerLevel * 10);

    return TreasureChest(
      x: x,
      y: y,
      coinValue: coinValue,
      type: type,
    );
  }
}

enum ChestType {
  wooden,
  silver,
  golden,
}
