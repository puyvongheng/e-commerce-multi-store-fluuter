import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';

class KhmerHillRiderPage extends StatefulWidget {
  const KhmerHillRiderPage({super.key});

  @override
  State<KhmerHillRiderPage> createState() => _KhmerHillRiderPageState();
}

class _KhmerHillRiderPageState extends State<KhmerHillRiderPage>
    with TickerProviderStateMixin {
  // Game state
  bool isPlaying = false;
  double distance = 0;
  double fuel = 100;
  int score = 0;
  int coins = 0;

  // Physics constants
  double playerY = 0;
  double velocityY = 0;
  double rotation = 0;
  double speed = 0;
  static const double gravity = 0.5;
  static const double friction = 0.98;
  bool isAccelerating = false;
  bool isBraking = false;

  String selectedVehicle = '🛵'; // 🛵, 🚜, 🛻
  String mapTheme = 'Village'; // Village, Rice Field, Hill

  late Timer gameTimer;
  List<double> hillPoints = [];
  List<Map<String, dynamic>> obstacles = [];

  late AnimationController _wheelController;

  @override
  void initState() {
    super.initState();
    _generateHills();
    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _generateHills() {
    hillPoints = [];
    double currentH = 300;
    for (int i = 0; i < 500; i++) {
      hillPoints.add(currentH);
      currentH += (math.Random().nextDouble() - 0.5) * 40;
      currentH = currentH.clamp(200.0, 500.0);
    }
  }

  void _startGame() {
    setState(() {
      isPlaying = true;
      distance = 0;
      fuel = 100;
      score = 0;
      coins = 0;
      playerY = hillPoints[0];
      velocityY = 0;
      rotation = 0;
      speed = 0;
      obstacles = [];
      _generateObstacles();
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      _update();
    });
  }

  void _generateObstacles() {
    for (int i = 1; i < 50; i++) {
      obstacles.add({
        'x': i * 400.0 + math.Random().nextDouble() * 200,
        'type': math.Random().nextDouble() > 0.7 ? '🐄' : '🪵',
      });
    }
    // Add fuel items
    for (int i = 1; i < 30; i++) {
      obstacles.add({
        'x': i * 600.0 + 300,
        'type': '⛽',
      });
    }
    // Add coins
    for (int i = 1; i < 60; i++) {
      obstacles.add({
        'x': i * 300.0 + 150,
        'type': '🪙',
      });
    }
  }

  void _update() {
    if (!isPlaying) return;

    setState(() {
      // Handle acceleration and braking
      if (isAccelerating && fuel > 0) {
        speed += 0.8;
        speed = speed.clamp(0, 15);
        _wheelController.repeat();
      } else if (isBraking) {
        speed -= 0.5;
        speed = speed.clamp(0, 15);
      }

      speed *= friction;

      // Update distance based on speed
      distance += speed;
      fuel -= 0.05 + (speed.abs() * 0.03);

      if (fuel <= 0) {
        _gameOver("អស់ប្រេងហើយ! ⛽");
        return;
      }

      // Physics - Find current hill height
      int currentIdx = (distance / 40).floor();
      if (currentIdx >= hillPoints.length - 2) {
        _gameOver("ឈ្នះហើយ! 🏁");
        return;
      }

      double t = (distance % 40) / 40;
      double groundY =
          (1 - t) * hillPoints[currentIdx] + t * hillPoints[currentIdx + 1];

      // Gravity and Ground collision
      if (playerY < groundY) {
        velocityY += gravity;
        playerY += velocityY;
      } else {
        playerY = groundY;
        velocityY = 0;
      }

      // Adjust rotation to hill slope
      double targetRot =
          math.atan2(hillPoints[currentIdx + 1] - hillPoints[currentIdx], 40);
      rotation = rotation + (targetRot - rotation) * 0.1;

      // Check obstacles
      obstacles.removeWhere((obs) {
        if ((obs['x'] - distance).abs() < 30) {
          if (obs['type'] == '⛽') {
            fuel = (fuel + 30).clamp(0, 100);
            return true;
          } else if (obs['type'] == '🪙') {
            coins += 10;
            score += 50;
            return true;
          } else if (obs['type'] == '🐄' || obs['type'] == '🪵') {
            _gameOver("បុកបាត់! ${obs['type']} 💥");
            return false;
          }
        }
        return obs['x'] < distance - 100;
      });

      score = distance.toInt() + coins;
    });
  }

  void _gameOver(String message) {
    gameTimer.cancel();
    _wheelController.stop();
    setState(() => isPlaying = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.contains('ឈ្នះ') ? '🏆' : '💥',
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ចម្ងាយ:',
                            style: TextStyle(color: Colors.white70)),
                        Text('$score m',
                            style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('កាក់:',
                            style: TextStyle(color: Colors.white70)),
                        Text('$coins 🪙',
                            style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('ចេញ'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _startGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('លេងម្តងទៀត',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (isPlaying) gameTimer.cancel();
    _wheelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBgColor(),
      body: Stack(
        children: [
          _buildEnvironment(),
          _buildHills(),
          ...obstacles.map((obs) => _buildObstacle(obs)).toList(),
          _buildPlayer(),
          _buildHUD(),
          if (isPlaying) _buildControls(),
          if (!isPlaying) _buildStartMenu(),
        ],
      ),
    );
  }

  Color _getBgColor() {
    switch (mapTheme) {
      case 'Rice Field':
        return const Color(0xFFE8F5E9);
      case 'Hill':
        return const Color(0xFFE1F5FE);
      default:
        return const Color(0xFFF1F8E9);
    }
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.4)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.speed,
                              color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "$score m",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('⛽', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Container(
                            width: 100,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: fuel / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: fuel > 30
                                        ? [Colors.green, Colors.lightGreen]
                                        : [Colors.orange, Colors.red],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withOpacity(0.8),
                        Colors.orange.withOpacity(0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        '$coins',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Brake Button
            GestureDetector(
              onTapDown: (_) => setState(() => isBraking = true),
              onTapUp: (_) => setState(() => isBraking = false),
              onTapCancel: () => setState(() => isBraking = false),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isBraking
                        ? [Colors.red.shade700, Colors.red.shade900]
                        : [Colors.red.shade400, Colors.red.shade600],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: isBraking ? 25 : 15,
                      spreadRadius: isBraking ? 5 : 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.close,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ).animate(target: isBraking ? 1 : 0).scale(
                  begin: const Offset(1, 1), end: const Offset(0.9, 0.9)),
            ),
            // Gas Button
            GestureDetector(
              onTapDown: (_) => setState(() => isAccelerating = true),
              onTapUp: (_) => setState(() => isAccelerating = false),
              onTapCancel: () => setState(() => isAccelerating = false),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isAccelerating
                        ? [Colors.green.shade700, Colors.green.shade900]
                        : [Colors.green.shade400, Colors.green.shade600],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.6),
                      blurRadius: isAccelerating ? 30 : 20,
                      spreadRadius: isAccelerating ? 8 : 3,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                    const Text(
                      'GAS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(target: isAccelerating ? 1 : 0)
                  .scale(
                      begin: const Offset(1, 1), end: const Offset(0.95, 0.95))
                  .shake(hz: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return Positioned(
      bottom: 600 - playerY,
      left: 100,
      child: Transform.rotate(
        angle: rotation,
        child: Text(selectedVehicle, style: const TextStyle(fontSize: 60))
            .animate(target: speed > 2 ? 1 : 0)
            .shake(hz: 8, curve: Curves.easeInOut),
      ),
    );
  }

  Widget _buildHills() {
    return CustomPaint(
      painter: HillPainter(
          hillPoints: hillPoints, distance: distance, theme: mapTheme),
      child: Container(),
    );
  }

  Widget _buildObstacle(Map<String, dynamic> obs) {
    double obsX = obs['x'] - distance + 100;
    if (obsX < -100 || obsX > 1000) return const SizedBox.shrink();

    // Find hill height at obs x
    int idx = (obs['x'] / 40).floor();
    if (idx >= hillPoints.length) return const SizedBox.shrink();
    double y = hillPoints[idx];

    return Positioned(
      bottom: 600 - y,
      left: obsX,
      child: Text(obs['type'], style: const TextStyle(fontSize: 40))
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.5)),
    );
  }

  Widget _buildEnvironment() {
    return Positioned.fill(
      child: Column(
        children: [
          const Spacer(),
          if (mapTheme == 'Rice Field')
            Icon(Icons.grass, size: 200, color: Colors.green.withOpacity(0.1)),
          if (mapTheme == 'Village')
            Icon(Icons.house_siding_rounded,
                size: 200, color: Colors.brown.withOpacity(0.1)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStartMenu() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      width: double.infinity,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "🏍️",
              style: TextStyle(fontSize: 80),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scale(duration: 1.seconds),
            const SizedBox(height: 20),
            const Text(
              "KHMER HILL RIDER",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.amber,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.orange,
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "ជិះភ្នំខ្មែរ",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "ជ្រើសរើសយានជំនិះ",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['🛵', '🚜', '🛻']
                  .map((v) => GestureDetector(
                        onTap: () => setState(() => selectedVehicle = v),
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: selectedVehicle == v
                                ? LinearGradient(
                                    colors: [Colors.amber, Colors.orange],
                                  )
                                : null,
                            color: selectedVehicle == v ? null : Colors.white12,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selectedVehicle == v
                                  ? Colors.white
                                  : Colors.white24,
                              width: 3,
                            ),
                            boxShadow: selectedVehicle == v
                                ? [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.5),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(v, style: const TextStyle(fontSize: 50)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 30),
            const Text(
              "ជ្រើសរើសផែនទី",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 12,
              children: ['Village', 'Rice Field', 'Hill']
                  .map((t) => ChoiceChip(
                        label: Text(
                          t,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: mapTheme == t ? Colors.black : Colors.white,
                          ),
                        ),
                        selected: mapTheme == t,
                        selectedColor: Colors.amber,
                        backgroundColor: Colors.white12,
                        onSelected: (_) => setState(() => mapTheme = t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  child: const Text(
                    "ចាប់ផ្តើមជិះ",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .shimmer(
                    duration: 2.seconds, color: Colors.white.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

class HillPainter extends CustomPainter {
  final List<double> hillPoints;
  final double distance;
  final String theme;

  HillPainter(
      {required this.hillPoints, required this.distance, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getGroundColor()
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (int i = 0; i < hillPoints.length; i++) {
      double x = i * 40.0 - distance + 100;
      if (x > -100 && x < size.width + 100) {
        path.lineTo(x, 600 - hillPoints[i]);
      }
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Draw grass line
    final linePaint = Paint()
      ..color = Colors.green.shade700
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    bool first = true;
    for (int i = 0; i < hillPoints.length; i++) {
      double x = i * 40.0 - distance + 100;
      if (x > -100 && x < size.width + 100) {
        if (first) {
          linePath.moveTo(x, 600 - hillPoints[i]);
          first = false;
        } else {
          linePath.lineTo(x, 600 - hillPoints[i]);
        }
      }
    }
    canvas.drawPath(linePath, linePaint);
  }

  Color _getGroundColor() {
    switch (theme) {
      case 'Rice Field':
        return Colors.brown.shade300;
      case 'Hill':
        return Colors.green.shade800;
      default:
        return Colors.brown.shade400;
    }
  }

  @override
  bool shouldRepaint(covariant HillPainter oldDelegate) =>
      oldDelegate.distance != distance;
}
