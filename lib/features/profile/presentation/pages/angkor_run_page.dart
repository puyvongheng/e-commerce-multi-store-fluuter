import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';

class AngkorRunPage extends StatefulWidget {
  const AngkorRunPage({super.key});

  @override
  State<AngkorRunPage> createState() => _AngkorRunPageState();
}

class _AngkorRunPageState extends State<AngkorRunPage> {
  // Game constants
  static const double playerWidth = 60.0;
  static const double playerHeight = 80.0;
  static const double obstacleWidth = 50.0;
  static const double obstacleHeight = 50.0;
  static const int fps = 60;

  // Game state
  bool isPlaying = false;
  double playerY = 0;
  double playerX = 0; // -1 (left), 0 (center), 1 (right)
  double time = 0;
  double height = 0;
  double velocity = 0;
  double gravity = -0.15;
  int score = 0;
  int highScore = 0;

  List<Map<String, double>> obstacles = [];
  late Timer gameTimer;
  double gameSpeed = 5.0;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      isPlaying = false;
      playerY = 0;
      playerX = 0;
      score = 0;
      obstacles = [];
      gameSpeed = 5.0;
    });
  }

  void _startGame() {
    _resetGame();
    setState(() => isPlaying = true);
    gameTimer =
        Timer.periodic(const Duration(milliseconds: 1000 ~/ fps), (timer) {
      _update();
    });
  }

  void _jump() {
    if (playerY == 0) {
      setState(() {
        velocity = 4.5;
      });
    }
  }

  void _move(double direction) {
    setState(() {
      playerX = direction.clamp(-1.0, 1.0);
    });
  }

  void _update() {
    setState(() {
      // Apply gravity
      playerY += velocity;
      velocity += gravity;

      if (playerY < 0) {
        playerY = 0;
        velocity = 0;
      }

      // Update obstacles
      for (var obs in obstacles) {
        obs['y'] = obs['y']! - gameSpeed;
      }

      // Remove off-screen obstacles
      obstacles.removeWhere((obs) => obs['y']! < -100);

      // Add new obstacles
      if (obstacles.isEmpty || obstacles.last['y']! < 400) {
        if (math.Random().nextDouble() < 0.02) {
          obstacles.add({
            'x': (math.Random().nextInt(3) - 1).toDouble(),
            'y': 800.0,
            'type': math.Random().nextInt(2).toDouble(), // 0: Ground, 1: Air
          });
        }
      }

      // Check collisions
      for (var obs in obstacles) {
        if (obs['x'] == playerX) {
          double obsY = obs['y']!;
          // Ground obstacle collision
          if (obs['type'] == 0 && obsY < 100 && obsY > 20 && playerY < 40) {
            _gameOver();
          }
          // Air obstacle (bird) collision
          if (obs['type'] == 1 && obsY < 100 && obsY > 20 && playerY > 30) {
            _gameOver();
          }
        }
      }

      score++;
      if (score % 500 == 0) gameSpeed += 0.5;
    });
  }

  void _gameOver() {
    gameTimer.cancel();
    setState(() {
      isPlaying = false;
      if (score > highScore) highScore = score;
    });
    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Game Over! 🛕',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $score',
                style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('High Score: $highScore',
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startGame();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent),
              child: const Text('Play Again',
                  style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (isPlaying) gameTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < -10) _jump();
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 10) _move(1);
          if (details.delta.dx < -10) _move(-1);
          if (details.delta.dx.abs() < 5) _move(0);
        },
        child: Stack(
          children: [
            // Background (Temple Run Vibes)
            _buildBackground(),

            // Ground/Path
            _buildPath(),

            // Obstacles
            ...obstacles.map((obs) => _buildObstacle(obs)).toList(),

            // Player (Hanuman or Archer)
            _buildPlayer(),

            // UI
            _buildUI(),

            if (!isPlaying) _buildStartOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF334155)],
        ),
      ),
      child: Opacity(
        opacity: 0.1,
        child: Center(
          child: Icon(Icons.castle_rounded,
              size: 300, color: Colors.orange.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildPath() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 200,
      child: Row(
        children: List.generate(
            3,
            (i) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.orange.withOpacity(0.1),
                          Colors.orange.withOpacity(0.3),
                        ],
                      ),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(50)),
                    ),
                  ),
                )),
      ),
    );
  }

  Widget _buildPlayer() {
    double screenWidth = MediaQuery.of(context).size.width;
    double laneWidth = screenWidth / 3;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      bottom: 150 + playerY,
      left: (screenWidth / 2) - (playerWidth / 2) + (playerX * laneWidth),
      child: Column(
        children: [
          const Text('🐒', style: TextStyle(fontSize: 50)), // Hanuman
          Container(
            width: 40,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(50),
            ),
          ).animate(target: playerY > 0 ? 0 : 1).scale(duration: 200.ms),
        ],
      ),
    );
  }

  Widget _buildObstacle(Map<String, double> obs) {
    double screenWidth = MediaQuery.of(context).size.width;
    double laneWidth = screenWidth / 3;
    bool isBird = obs['type'] == 1;

    return Positioned(
      bottom: 150 + obs['y']! + (isBird ? 60 : 0),
      left: (screenWidth / 2) - (obstacleWidth / 2) + (obs['x']! * laneWidth),
      child: Text(isBird ? '🦅' : '🪵', style: const TextStyle(fontSize: 40)),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('SCORE',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 12)),
                Text('$score',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ANGKOR RUN',
                style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5)),
            const Text('រត់កាត់ប្រាសាទអង្គរ',
                style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 40),
            const Text('Swipe UP to Jump\nSwipe LEFT/RIGHT to Move',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('START ADVENTURE',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
