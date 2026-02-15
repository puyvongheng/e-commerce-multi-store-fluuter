import 'dart:math' as math;

class WaterBubble {
  double x;
  double y;
  double size;
  double speed;
  double animationTime = 0;
  final double opacity;

  WaterBubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  void update() {
    y -= speed; // Rise up
    x += math.sin(animationTime) * 0.5; // Wobble
    animationTime += 0.1;
  }

  bool isOffScreen() => y < -50;

  static WaterBubble createRandom(double screenWidth, double screenHeight) {
    final random = math.Random();
    return WaterBubble(
      x: random.nextDouble() * screenWidth,
      y: screenHeight + 10,
      size: random.nextDouble() * 20 + 10,
      speed: random.nextDouble() * 2 + 1,
      opacity: random.nextDouble() * 0.3 + 0.2,
    );
  }
}

class UnderwaterRock {
  final double x;
  final double y;
  final double size;
  final String type; // 'small', 'medium', 'large'
  final String emoji;

  UnderwaterRock({
    required this.x,
    required this.y,
    required this.size,
    required this.type,
    required this.emoji,
  });

  bool checkBulletCollision(double bulletX, double bulletY) {
    final distance =
        math.sqrt(math.pow(bulletX - x, 2) + math.pow(bulletY - y, 2));
    return distance < size / 2;
  }

  static UnderwaterRock createRandom(double screenWidth, double screenHeight) {
    final random = math.Random();
    final types = [
      {'type': 'small', 'emoji': '🪨', 'size': 40.0},
      {'type': 'medium', 'emoji': '🗿', 'size': 60.0},
      {'type': 'large', 'emoji': '⛰️', 'size': 80.0},
    ];

    final rockType = types[random.nextInt(types.length)];

    return UnderwaterRock(
      x: random.nextDouble() * screenWidth,
      y: random.nextDouble() * (screenHeight - 200) + 100,
      size: rockType['size'] as double,
      type: rockType['type'] as String,
      emoji: rockType['emoji'] as String,
    );
  }
}

class Seaweed {
  final double x;
  final double y;
  final double height;
  double swayAngle = 0;
  final double swaySpeed;
  bool isHit = false;
  int hitCooldown = 0;

  Seaweed({
    required this.x,
    required this.y,
    required this.height,
    required this.swaySpeed,
  });

  void update() {
    swayAngle += swaySpeed;
    if (isHit) {
      hitCooldown--;
      if (hitCooldown <= 0) {
        isHit = false;
      }
    }
  }

  void onHit() {
    isHit = true;
    hitCooldown = 30;
  }

  bool obscuresFish(double fishX, double fishY) {
    final distance = math.sqrt(math.pow(fishX - x, 2) + math.pow(fishY - y, 2));
    return distance < 30;
  }

  static Seaweed createRandom(double screenWidth, double screenHeight) {
    final random = math.Random();
    return Seaweed(
      x: random.nextDouble() * screenWidth,
      y: screenHeight - 50,
      height: random.nextDouble() * 100 + 80,
      swaySpeed: random.nextDouble() * 0.02 + 0.01,
    );
  }
}

class WaterCurrent {
  final String direction; // 'left', 'right', 'up', 'down'
  final double strength;
  int duration;
  final int maxDuration;

  WaterCurrent({
    required this.direction,
    required this.strength,
    required this.duration,
  }) : maxDuration = duration;

  void update() {
    if (duration > 0) duration--;
  }

  bool isActive() => duration > 0;

  double get remainingPercentage => duration / maxDuration;

  void applyToBullet(double currentVx, double currentVy) {
    // Returns modified velocity
  }

  static WaterCurrent createRandom() {
    final random = math.Random();
    final directions = ['left', 'right', 'up', 'down'];

    return WaterCurrent(
      direction: directions[random.nextInt(directions.length)],
      strength: random.nextDouble() * 2 + 1,
      duration: 300 + random.nextInt(300), // 5-10 seconds
    );
  }
}

class Whirlpool {
  final double x;
  final double y;
  final double radius;
  final double pullStrength;
  double rotationAngle = 0;
  int lifetime;

  Whirlpool({
    required this.x,
    required this.y,
    required this.radius,
    required this.pullStrength,
    required this.lifetime,
  });

  void update() {
    rotationAngle += 0.1;
    if (lifetime > 0) lifetime--;
  }

  bool isActive() => lifetime > 0;

  Map<String, double> applyPull(double objectX, double objectY) {
    final dx = x - objectX;
    final dy = y - objectY;
    final distance = math.sqrt(dx * dx + dy * dy);

    if (distance < radius) {
      final pullFactor = (1 - distance / radius) * pullStrength;
      final angle = math.atan2(dy, dx);

      return {
        'vx': math.cos(angle) * pullFactor,
        'vy': math.sin(angle) * pullFactor,
      };
    }

    return {'vx': 0, 'vy': 0};
  }

  static Whirlpool createRandom(double screenWidth, double screenHeight) {
    final random = math.Random();
    return Whirlpool(
      x: random.nextDouble() * screenWidth,
      y: random.nextDouble() * (screenHeight - 200) + 100,
      radius: 150,
      pullStrength: 3,
      lifetime: 600, // 10 seconds
    );
  }
}

class LightRay {
  final double x;
  final double width;
  final double opacity;
  double animationTime = 0;
  final double animationSpeed;

  LightRay({
    required this.x,
    required this.width,
    required this.opacity,
    required this.animationSpeed,
  });

  void update() {
    animationTime += animationSpeed;
  }

  double getCurrentOpacity() {
    return opacity * (0.5 + math.sin(animationTime) * 0.5);
  }

  static List<LightRay> createRays(double screenWidth, int count) {
    final random = math.Random();
    final rays = <LightRay>[];

    for (int i = 0; i < count; i++) {
      rays.add(LightRay(
        x: random.nextDouble() * screenWidth,
        width: random.nextDouble() * 100 + 50,
        opacity: random.nextDouble() * 0.2 + 0.1,
        animationSpeed: random.nextDouble() * 0.02 + 0.01,
      ));
    }

    return rays;
  }
}
