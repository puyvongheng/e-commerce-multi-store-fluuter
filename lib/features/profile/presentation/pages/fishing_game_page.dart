import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/services/api_service.dart';

class FishingGamePage extends StatefulWidget {
  const FishingGamePage({super.key});

  @override
  State<FishingGamePage> createState() => _FishingGamePageState();
}

class _FishingGamePageState extends State<FishingGamePage>
    with TickerProviderStateMixin {
  // Game state
  bool isPlaying = false;
  int coins = 0;
  int score = 0;
  int totalCoinsEarned = 0;
  int totalFishKilled = 0;

  // Level & XP System
  int playerLevel = 1;
  int currentXP = 0;
  int xpToNextLevel = 100;
  int prestigeLevel = 0;

  // Weapon stats
  int weaponLevel = 1;
  int weaponPower = 1;
  int weaponSpeed = 1000;
  int bulletCount = 1;
  String weaponType = '🎣';
  String bulletEmoji = '•';
  Color bulletColor = Colors.orange;

  // Extended Upgrades
  int powerUpgradeCost = 50;
  int speedUpgradeCost = 75;
  int weaponUpgradeCost = 100;
  int multiShotCost = 150;
  int critChanceCost = 200;
  int critDamageCost = 250;
  int coinMultiplierCost = 300;
  int autoShootCost = 500;
  int magnetRangeCost = 400;

  // New upgrade stats
  double critChance = 0.0; // 0-100%
  double critDamage = 1.5; // multiplier
  double coinMultiplier = 1.0;
  bool autoShoot = false;
  double magnetRange = 0;

  // Achievements
  Set<String> unlockedAchievements = {};
  bool showAchievementPopup = false;
  String? lastAchievement;

  // Daily Missions
  Map<String, int> dailyMissions = {
    'kill_fish': 0,
    'earn_coins': 0,
    'use_powers': 0,
  };
  Map<String, int> dailyGoals = {
    'kill_fish': 50,
    'earn_coins': 500,
    'use_powers': 5,
  };
  bool dailyRewardClaimed = false;

  // Fish
  List<Fish> fishes = [];
  List<Bullet> bullets = [];
  List<Particle> particles = [];
  List<PowerUp> powerUps = [];

  late Timer gameTimer;
  late Timer fishSpawnTimer;
  Timer? autoShootTimer;
  final random = math.Random();

  // Cannon position
  double cannonX = 0;
  double cannonY = 0;
  double cannonAngle = -math.pi / 2;

  bool showUpgradeMenu = false;
  bool showAchievementsMenu = false;
  bool showMissionsMenu = false;
  late AnimationController _shootController;
  late AnimationController _recoilController;

  // Super Powers (វេទមន្ត)
  String? activePower;
  int powerTimeLeft = 0;
  Timer? powerTimer;

  // Power effects backup
  int savedWeaponPower = 1;
  int savedBulletCount = 1;
  String savedBulletEmoji = '•';
  Color savedBulletColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    _shootController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _recoilController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    // Fetch immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserCoins();
    });
  }

  Future<void> _fetchUserCoins() async {
    try {
      final profile = await ApiService.getProfile();
      if (profile['user'] != null && profile['user']['coins'] != null) {
        setState(() {
          coins = profile['user']['coins'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching coins: $e");
    }
  }

  Future<void> _saveAndExit() async {
    // Save progress to server
    if (totalCoinsEarned > 0) {
      try {
        await ApiService.claimReward(
          gameName: 'Fishing Game',
          score: score, // Optional tracking
          coins: totalCoinsEarned,
        );
        // Refresh coins after saving
        await _fetchUserCoins();
      } catch (e) {
        debugPrint("Error saving progress: $e");
        // Proceed to exit anyway, or show error dialog
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save progress: $e')),
          );
        }
      }
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _startGame() {
    setState(() {
      isPlaying = true;
      fishes.clear();
      bullets.clear();
      particles.clear();
      powerUps.clear();
      activePower = null;
      powerTimeLeft = 0;
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      _updateGame();
    });

    fishSpawnTimer =
        Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _spawnFish();
    });
  }

  void _spawnFish() {
    if (!isPlaying) return;

    final types = [
      {'emoji': '🐟', 'hp': 1, 'coins': 5, 'speed': 2.0, 'size': 40.0},
      {'emoji': '🐠', 'hp': 2, 'coins': 10, 'speed': 1.5, 'size': 45.0},
      {'emoji': '🐡', 'hp': 3, 'coins': 15, 'speed': 1.0, 'size': 50.0},
      {'emoji': '🦈', 'hp': 5, 'coins': 30, 'speed': 1.2, 'size': 60.0},
      {'emoji': '🐙', 'hp': 8, 'coins': 50, 'speed': 0.8, 'size': 65.0},
      {'emoji': '🦑', 'hp': 10, 'coins': 75, 'speed': 0.7, 'size': 70.0},
      {'emoji': '🐳', 'hp': 15, 'coins': 100, 'speed': 0.5, 'size': 80.0},
    ];

    final fishType = types[random.nextInt(types.length)];
    final startFromLeft = random.nextBool();

    setState(() {
      fishes.add(Fish(
        x: startFromLeft ? -50 : MediaQuery.of(context).size.width + 50,
        y: random.nextDouble() * (MediaQuery.of(context).size.height - 350) +
            120,
        emoji: fishType['emoji'] as String,
        hp: fishType['hp'] as int,
        maxHp: fishType['hp'] as int,
        coins: fishType['coins'] as int,
        speed: (fishType['speed'] as double) * (startFromLeft ? 1 : -1),
        size: fishType['size'] as double,
      ));
    });
  }

  void _spawnPowerUp(double x, double y) {
    final powerTypes = [
      {'type': 'rapid', 'emoji': '⚡', 'color': Colors.yellow},
      {'type': 'mega', 'emoji': '💪', 'color': Colors.red},
      {'type': 'lightning', 'emoji': '🌩️', 'color': Colors.cyan},
      {'type': 'freeze', 'emoji': '❄️', 'color': Colors.blue},
    ];

    if (random.nextDouble() < 0.3) {
      final power = powerTypes[random.nextInt(powerTypes.length)];
      setState(() {
        powerUps.add(PowerUp(
          x: x,
          y: y,
          type: power['type'] as String,
          emoji: power['emoji'] as String,
          color: power['color'] as Color,
        ));
      });
    }
  }

  void _activatePower(String type) {
    if (activePower != null) return;

    setState(() {
      activePower = type;
      powerTimeLeft = 10;

      // Save current stats
      savedWeaponPower = weaponPower;
      savedBulletCount = bulletCount;
      savedBulletEmoji = bulletEmoji;
      savedBulletColor = bulletColor;

      // Apply power effects
      switch (type) {
        case 'rapid':
          bulletCount = bulletCount + 3;
          bulletEmoji = '⚡';
          bulletColor = Colors.yellow;
          break;
        case 'mega':
          weaponPower = weaponPower * 5;
          bulletEmoji = '💥';
          bulletColor = Colors.red;
          break;
        case 'lightning':
          bulletCount = bulletCount + 5;
          weaponPower = weaponPower * 2;
          bulletEmoji = '🌩️';
          bulletColor = Colors.cyan;
          break;
        case 'freeze':
          // Freeze all fish
          for (var fish in fishes) {
            fish.speed = 0;
          }
          bulletEmoji = '❄️';
          bulletColor = Colors.blue;
          break;
      }
    });

    // Start countdown
    powerTimer?.cancel();
    powerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        powerTimeLeft--;
        if (powerTimeLeft <= 0) {
          _deactivatePower();
          timer.cancel();
        }
      });
    });
  }

  void _deactivatePower() {
    setState(() {
      // Restore original stats
      weaponPower = savedWeaponPower;
      bulletCount = savedBulletCount;
      bulletEmoji = savedBulletEmoji;
      bulletColor = savedBulletColor;
      activePower = null;
      powerTimeLeft = 0;
    });
  }

  void _updateGame() {
    if (!isPlaying) return;

    setState(() {
      // Update fish positions
      fishes = fishes.where((fish) {
        if (activePower != 'freeze') {
          fish.x += fish.speed;
        }
        fish.animationTime += 0.05;
        return fish.x > -100 &&
            fish.x < MediaQuery.of(context).size.width + 100;
      }).toList();

      // Update power-ups
      powerUps = powerUps.where((powerUp) {
        powerUp.y += 1;
        powerUp.animationTime += 0.1;

        // Check collection
        final distance = math.sqrt(math.pow(powerUp.x - cannonX, 2) +
            math.pow(powerUp.y - cannonY, 2));

        if (distance < 60) {
          _activatePower(powerUp.type);
          return false;
        }

        return powerUp.y < MediaQuery.of(context).size.height;
      }).toList();

      // Update bullets
      bullets = bullets.where((bullet) {
        bullet.x += math.cos(bullet.angle) * bullet.speed;
        bullet.y += math.sin(bullet.angle) * bullet.speed;
        bullet.lifetime++;

        // Check collision with fish
        for (var fish in fishes) {
          final distance = math.sqrt(
              math.pow(bullet.x - fish.x, 2) + math.pow(bullet.y - fish.y, 2));

          if (distance < fish.size / 2) {
            fish.hp -= weaponPower;
            _createHitParticles(fish.x, fish.y, fish.hp <= 0);

            if (fish.hp <= 0) {
              coins += fish.coins;
              score += fish.coins;
              _createCoinParticles(fish.x, fish.y, fish.coins);
              _spawnPowerUp(fish.x, fish.y);
              fishes.remove(fish);
            }
            return false;
          }
        }

        return bullet.x > -50 &&
            bullet.x < MediaQuery.of(context).size.width + 50 &&
            bullet.y > -50 &&
            bullet.y < MediaQuery.of(context).size.height + 50 &&
            bullet.lifetime < 200;
      }).toList();

      // Update particles
      particles = particles.where((particle) {
        particle.x += particle.vx;
        particle.y += particle.vy;
        particle.vy += 0.3;
        particle.lifetime--;
        particle.opacity -= 0.02;
        return particle.lifetime > 0 && particle.opacity > 0;
      }).toList();
    });
  }

  void _createHitParticles(double x, double y, bool isFatal) {
    for (int i = 0; i < (isFatal ? 15 : 5); i++) {
      particles.add(Particle(
        x: x,
        y: y,
        vx: (random.nextDouble() - 0.5) * 8,
        vy: (random.nextDouble() - 0.5) * 8,
        color: isFatal ? Colors.amber : Colors.white,
        size: random.nextDouble() * 8 + 4,
        lifetime: 30,
        opacity: 1.0,
      ));
    }
  }

  void _createCoinParticles(double x, double y, int coinValue) {
    for (int i = 0; i < 10; i++) {
      particles.add(Particle(
        x: x,
        y: y,
        vx: (random.nextDouble() - 0.5) * 6,
        vy: -random.nextDouble() * 8 - 2,
        color: Colors.amber,
        size: 12,
        lifetime: 40,
        opacity: 1.0,
        emoji: '🪙',
      ));
    }
  }

  void _shoot(Offset position) {
    if (!isPlaying) return;

    final dx = position.dx - cannonX;
    final dy = position.dy - cannonY;
    final angle = math.atan2(dy, dx);

    setState(() {
      cannonAngle = angle;

      for (int i = 0; i < bulletCount; i++) {
        final spreadAngle =
            bulletCount > 1 ? angle + (i - bulletCount / 2) * 0.15 : angle;

        bullets.add(Bullet(
          x: cannonX + math.cos(angle) * 50,
          y: cannonY + math.sin(angle) * 50,
          angle: spreadAngle,
          speed: 10 + weaponLevel * 2,
          color: bulletColor,
          emoji: bulletEmoji,
          size: 8 + weaponLevel * 2,
        ));
      }

      // Muzzle flash
      for (int i = 0; i < 8; i++) {
        particles.add(Particle(
          x: cannonX + math.cos(angle) * 50,
          y: cannonY + math.sin(angle) * 50,
          vx: math.cos(angle + (random.nextDouble() - 0.5) * 0.5) * 5,
          vy: math.sin(angle + (random.nextDouble() - 0.5) * 0.5) * 5,
          color: bulletColor,
          size: random.nextDouble() * 6 + 3,
          lifetime: 15,
          opacity: 1.0,
        ));
      }
    });

    _shootController.forward(from: 0);
    _recoilController.forward(from: 0);
  }

  void _upgradePower() {
    if (coins >= powerUpgradeCost) {
      setState(() {
        coins -= powerUpgradeCost;
        weaponPower++;
        savedWeaponPower = weaponPower;
        powerUpgradeCost = (powerUpgradeCost * 1.5).toInt();
      });
    }
  }

  void _upgradeSpeed() {
    if (coins >= speedUpgradeCost && weaponSpeed > 300) {
      setState(() {
        coins -= speedUpgradeCost;
        weaponSpeed -= 100;
        speedUpgradeCost = (speedUpgradeCost * 1.5).toInt();
      });
    }
  }

  void _upgradeMultiShot() {
    if (coins >= multiShotCost && bulletCount < 5) {
      setState(() {
        coins -= multiShotCost;
        bulletCount++;
        savedBulletCount = bulletCount;
        multiShotCost = (multiShotCost * 1.8).toInt();
      });
    }
  }

  void _upgradeWeapon() {
    if (coins >= weaponUpgradeCost) {
      setState(() {
        coins -= weaponUpgradeCost;
        weaponLevel++;

        if (weaponLevel == 2) {
          weaponType = '🔱';
          bulletEmoji = '⚡';
          bulletColor = Colors.yellow;
          weaponPower += 2;
        } else if (weaponLevel == 3) {
          weaponType = '💣';
          bulletEmoji = '💥';
          bulletColor = Colors.red;
          weaponPower += 3;
        } else if (weaponLevel == 4) {
          weaponType = '🚀';
          bulletEmoji = '🔥';
          bulletColor = Colors.orange;
          weaponPower += 4;
        } else if (weaponLevel >= 5) {
          weaponType = '⚛️';
          bulletEmoji = '✨';
          bulletColor = Colors.purple;
          weaponPower += 5;
        }

        savedWeaponPower = weaponPower;
        savedBulletEmoji = bulletEmoji;
        savedBulletColor = bulletColor;
        weaponUpgradeCost = (weaponUpgradeCost * 2).toInt();
      });
    }
  }

  @override
  void dispose() {
    if (isPlaying) {
      gameTimer.cancel();
      fishSpawnTimer.cancel();
    }
    powerTimer?.cancel();
    _shootController.dispose();
    _recoilController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    cannonX = MediaQuery.of(context).size.width / 2;
    cannonY = MediaQuery.of(context).size.height - 100;

    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          if (isPlaying && !showUpgradeMenu) {
            _shoot(details.localPosition);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: activePower != null
                  ? [
                      Color(0xFF4A148C),
                      Color(0xFF6A1B9A),
                      Color(0xFF8E24AA),
                    ]
                  : [
                      Color(0xFF0A1929),
                      Color(0xFF1E3A8A),
                      Color(0xFF3B82F6),
                    ],
            ),
          ),
          child: Stack(
            children: [
              _buildWaterEffect(),
              ...particles.map((p) => _buildParticle(p)).toList(),
              ...powerUps.map((p) => _buildPowerUp(p)).toList(),
              ...fishes.map((fish) => _buildFish(fish)).toList(),
              ...bullets.map((bullet) => _buildBullet(bullet)).toList(),
              if (isPlaying) _buildCannon(),
              _buildHUD(),
              if (activePower != null) _buildPowerIndicator(),
              if (!isPlaying) _buildStartMenu(),
              if (showUpgradeMenu) _buildUpgradeMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterEffect() {
    return Positioned.fill(
      child: CustomPaint(
        painter: WaterPainter(),
      ),
    );
  }

  Widget _buildPowerUp(PowerUp powerUp) {
    return Positioned(
      left: powerUp.x - 30,
      top: powerUp.y - 30,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              powerUp.color.withOpacity(0.8),
              powerUp.color.withOpacity(0.3),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: powerUp.color.withOpacity(0.8),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Text(
            powerUp.emoji,
            style: const TextStyle(fontSize: 35),
          ),
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
            duration: 1.seconds,
            begin: const Offset(1, 1),
            end: const Offset(1.2, 1.2))
        .rotate(duration: 2.seconds);
  }

  Widget _buildPowerIndicator() {
    final powerInfo = {
      'rapid': {'name': 'បាញ់លឿន', 'emoji': '⚡', 'color': Colors.yellow},
      'mega': {'name': 'កម្លាំងធំ', 'emoji': '💪', 'color': Colors.red},
      'lightning': {
        'name': 'ផ្លេកបន្ទោរ',
        'emoji': '🌩️',
        'color': Colors.cyan
      },
      'freeze': {'name': 'បង្កក', 'emoji': '❄️', 'color': Colors.blue},
    };

    final info = powerInfo[activePower]!;

    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (info['color'] as Color).withOpacity(0.9),
                (info['color'] as Color).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: (info['color'] as Color).withOpacity(0.8),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                info['emoji'] as String,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info['name'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$powerTimeLeft វិនាទី',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 1.seconds, color: Colors.white.withOpacity(0.5))
        .scale(
            duration: 500.ms,
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05));
  }

  Widget _buildParticle(Particle particle) {
    return Positioned(
      left: particle.x - particle.size / 2,
      top: particle.y - particle.size / 2,
      child: Opacity(
        opacity: particle.opacity.clamp(0.0, 1.0),
        child: particle.emoji != null
            ? Text(
                particle.emoji!,
                style: TextStyle(fontSize: particle.size),
              )
            : Container(
                width: particle.size,
                height: particle.size,
                decoration: BoxDecoration(
                  color: particle.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: particle.color.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHUD() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Exit Game?'),
                          content:
                              const Text('Your earned coins will be saved.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _saveAndExit();
                              },
                              child: const Text('Save & Exit'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        '$coins',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .shimmer(
                        duration: 2.seconds,
                        color: Colors.white.withOpacity(0.3)),
                if (isPlaying)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.deepPurple],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.upgrade,
                          color: Colors.white, size: 28),
                      onPressed: () =>
                          setState(() => showUpgradeMenu = !showUpgradeMenu),
                    ),
                  ),
              ],
            ),
            if (isPlaying)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: Row(
                        children: [
                          Text(
                            weaponType,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lv.$weaponLevel',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.flash_on,
                                      color: Colors.amber, size: 16),
                                  Text(
                                    '$weaponPower',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (bulletCount > 1) ...[
                                    const Icon(Icons.grain,
                                        color: Colors.cyan, size: 16),
                                    Text(
                                      'x$bulletCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                        .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true))
                        .shimmer(
                            duration: 3.seconds,
                            color: Colors.white.withOpacity(0.2)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFish(Fish fish) {
    return Positioned(
      left: fish.x - fish.size / 2,
      top: fish.y - fish.size / 2,
      child: Column(
        children: [
          if (fish.hp < fish.maxHp)
            Container(
              width: fish.size + 10,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fish.hp / fish.maxHp,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: fish.hp / fish.maxHp > 0.5
                          ? [Colors.green, Colors.lightGreen]
                          : fish.hp / fish.maxHp > 0.25
                              ? [Colors.orange, Colors.deepOrange]
                              : [Colors.red, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          Transform(
            transform: Matrix4.identity()
              ..scale(fish.speed > 0 ? 1.0 : -1.0, 1.0)
              ..translate(0.0, math.sin(fish.animationTime) * 5),
            alignment: Alignment.center,
            child: Text(
              fish.emoji,
              style: TextStyle(fontSize: fish.size),
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 3.seconds, color: Colors.white.withOpacity(0.1));
  }

  Widget _buildBullet(Bullet bullet) {
    return Positioned(
      left: bullet.x - bullet.size / 2,
      top: bullet.y - bullet.size / 2,
      child: Transform.rotate(
        angle: bullet.angle,
        child: bullet.emoji != '•'
            ? Text(
                bullet.emoji,
                style: TextStyle(fontSize: bullet.size * 2),
              )
            : Container(
                width: bullet.size,
                height: bullet.size,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white,
                      bullet.color,
                      bullet.color.withOpacity(0.5),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: bullet.color.withOpacity(0.8),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 500.ms, color: Colors.white.withOpacity(0.5));
  }

  Widget _buildCannon() {
    return AnimatedBuilder(
      animation: _recoilController,
      builder: (context, child) {
        final recoil = _recoilController.value * 10;

        return Positioned(
          left: cannonX - 50 - math.cos(cannonAngle) * recoil,
          top: cannonY - 50 - math.sin(cannonAngle) * recoil,
          child: Transform.rotate(
            angle: cannonAngle,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.grey.shade700,
                    Colors.grey.shade900,
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: activePower != null ? bulletColor : Colors.amber,
                  width: activePower != null ? 5 : 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: bulletColor.withOpacity(0.8),
                    blurRadius: activePower != null ? 25 : 15,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  weaponType,
                  style: const TextStyle(fontSize: 50),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartMenu() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🎣',
                  style: TextStyle(fontSize: 100),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .scale(duration: 1.seconds)
                    .rotate(duration: 2.seconds, begin: -0.1, end: 0.1),
                const SizedBox(height: 20),
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'បាញ់ត្រី',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.cyan,
                      shadows: [
                        Shadow(
                          color: Colors.blue,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'FISHING SHOOTER',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'របៀបលេង',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '• ចុចលើអេក្រង់ដើម្បីបាញ់ត្រី\n• ត្រីងាប់ទទួលបានកាក់\n• ប្រើកាក់ដើម្បីធ្វើឱ្យប្រសើរ\n• បាញ់ត្រីធំៗដើម្បីបានកាក់ច្រើន\n• ប្រមូលវេទមន្តពីត្រី 10វិនាទី',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.cyan, Colors.blue],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      child: const Text(
                        'ចាប់ផ្តើម',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .shimmer(
                        duration: 2.seconds,
                        color: Colors.white.withOpacity(0.5))
                    .scale(
                        duration: 1.seconds,
                        begin: const Offset(1, 1),
                        end: const Offset(1.05, 1.05)),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    'ចាកចេញ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeMenu() {
    return Center(
      child: Container(
        width: math.min(320, MediaQuery.of(context).size.width * 0.9),
        margin: const EdgeInsets.symmetric(vertical: 40),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade700,
              Colors.purple.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.6),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ធ្វើឱ្យប្រសើរ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => setState(() => showUpgradeMenu = false),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, thickness: 2),
              const SizedBox(height: 10),
              _buildUpgradeButton(
                icon: '⚡',
                title: 'កម្លាំង',
                level: weaponPower,
                cost: powerUpgradeCost,
                onTap: _upgradePower,
              ),
              const SizedBox(height: 12),
              _buildUpgradeButton(
                icon: '⏱️',
                title: 'ល្បឿន',
                level: (1000 - weaponSpeed) ~/ 100,
                cost: speedUpgradeCost,
                onTap: _upgradeSpeed,
                disabled: weaponSpeed <= 300,
              ),
              const SizedBox(height: 12),
              _buildUpgradeButton(
                icon: '🎯',
                title: 'គ្រាប់ច្រើន',
                level: bulletCount,
                cost: multiShotCost,
                onTap: _upgradeMultiShot,
                disabled: bulletCount >= 5,
              ),
              const SizedBox(height: 12),
              _buildUpgradeButton(
                icon: weaponType,
                title: 'អាវុធ',
                level: weaponLevel,
                cost: weaponUpgradeCost,
                onTap: _upgradeWeapon,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }

  Widget _buildUpgradeButton({
    required String icon,
    required String title,
    required int level,
    required int cost,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    final canAfford = coins >= cost && !disabled;

    return GestureDetector(
      onTap: canAfford ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: canAfford
              ? LinearGradient(
                  colors: [
                    Colors.amber.withOpacity(0.3),
                    Colors.orange.withOpacity(0.2),
                  ],
                )
              : null,
          color: canAfford ? null : Colors.black26,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: canAfford ? Colors.amber : Colors.white12,
            width: 3,
          ),
          boxShadow: canAfford
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    'Lv.$level',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: canAfford
                    ? const LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                      )
                    : null,
                color: canAfford ? null : Colors.grey,
                borderRadius: BorderRadius.circular(10),
                boxShadow: canAfford
                    ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    '$cost',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate(target: canAfford ? 1 : 0)
          .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.3)),
    );
  }
}

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
}

class Bullet {
  double x;
  double y;
  double angle;
  double speed;
  Color color;
  String emoji;
  double size;
  int lifetime = 0;

  Bullet({
    required this.x,
    required this.y,
    required this.angle,
    required this.speed,
    required this.color,
    required this.emoji,
    required this.size,
  });
}

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
  });
}

class PowerUp {
  double x;
  double y;
  String type;
  String emoji;
  Color color;
  double animationTime = 0;

  PowerUp({
    required this.x,
    required this.y,
    required this.type,
    required this.emoji,
    required this.color,
  });
}

class WaterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (int i = 0; i < 6; i++) {
      final path = Path();
      final y = size.height * (0.15 + i * 0.15);
      path.moveTo(0, y);

      for (double x = 0; x <= size.width; x += 20) {
        path.lineTo(x, y + math.sin(x / 50 + i) * 12);
      }

      canvas.drawPath(
          path,
          paint
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
