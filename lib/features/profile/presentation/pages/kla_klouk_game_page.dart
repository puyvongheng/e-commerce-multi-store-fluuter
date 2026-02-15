import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';

class KlaKloukGamePage extends StatefulWidget {
  const KlaKloukGamePage({super.key});

  @override
  State<KlaKloukGamePage> createState() => _KlaKloukGamePageState();
}

class _KlaKloukGamePageState extends State<KlaKloukGamePage>
    with TickerProviderStateMixin {
  final List<Map<String, String>> symbols = [
    {'name': 'Kla (Tiger)', 'icon': '🐯', 'kh': 'ខ្លា'},
    {'name': 'Klouk (Gourd)', 'icon': '🍶', 'kh': 'ឃ្លោក'},
    {'name': 'Moan (Chicken)', 'icon': '🐔', 'kh': 'មាន់'},
    {'name': 'Bangkang (Shrimp)', 'icon': '🦞', 'kh': 'បង្កង'},
    {'name': 'Kdam (Crab)', 'icon': '🦀', 'kh': 'ក្ដាម'},
    {'name': 'Trei (Fish)', 'icon': '🐟', 'kh': 'ត្រី'},
  ];

  List<int> diceResults = [0, 0, 0];
  Map<int, int> bets = {};
  int balance = 1000;
  bool isRolling = false;
  String message = "ដាក់ភ្នាល់! 🎲";

  late List<AnimationController> _diceControllers;
  final random = math.Random();

  @override
  void initState() {
    super.initState();
    _diceControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _diceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _placeBet(int index) {
    if (balance <= 0) {
      setState(() => message = "អស់លុយហើយ! 💸");
      return;
    }
    setState(() {
      bets[index] = (bets[index] ?? 0) + 100;
      balance -= 100;
      message = "ភ្នាល់លើ ${symbols[index]['kh']} ✓";
    });
  }

  void _clearBets() {
    setState(() {
      bets.forEach((key, value) => balance += value);
      bets.clear();
      message = "លុបភ្នាល់ហើយ";
    });
  }

  Future<void> _rollDice() async {
    if (bets.isEmpty) {
      setState(() => message = "សូមដាក់ភ្នាល់មុនសិន!");
      return;
    }

    setState(() {
      isRolling = true;
      message = "កំពុងរំកិល...";
    });

    // Start dice rolling animations
    for (var controller in _diceControllers) {
      controller.repeat();
    }

    // Animation delay
    await Future.delayed(const Duration(milliseconds: 2000));

    List<int> results = [
      random.nextInt(6),
      random.nextInt(6),
      random.nextInt(6),
    ];

    // Stop animations
    for (var controller in _diceControllers) {
      controller.stop();
      controller.reset();
    }

    int winAmount = 0;
    bets.forEach((symbolIndex, betAmount) {
      int occurrences = results.where((r) => r == symbolIndex).length;
      if (occurrences > 0) {
        winAmount += betAmount + (occurrences * betAmount);
      }
    });

    setState(() {
      diceResults = results;
      balance += winAmount;
      isRolling = false;
      if (winAmount > 0) {
        message = "អ្នកឈ្នះ $winAmount! 🎉";
      } else {
        message = "សាកម្តងទៀត! 🍀";
      }
      bets.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B4513), // Brown wood
              Color(0xFF654321),
              Color(0xFF3E2723),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildBalanceHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTraditionalBowl(),
                      const SizedBox(height: 30),
                      _buildBettingGrid(),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              const Text(
                'ខ្លាឃ្លោក',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.amber,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const Text(
                'KLA KLOUK',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBalanceHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFD700).withOpacity(0.3),
            Color(0xFFFFA500).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.account_balance_wallet,
                    color: Colors.brown, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'លុយសរុប:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            '\$$balance',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraditionalBowl() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Color(0xFF2C1810),
            Color(0xFF1A0F0A),
          ],
        ),
        borderRadius: BorderRadius.circular(200),
        border: Border.all(color: Color(0xFF8B4513), width: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Color(0xFF8B4513).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black87,
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF3E2723).withOpacity(0.5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _build3DDie(diceResults[index], index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DDie(int symbolIndex, int dieIndex) {
    return AnimatedBuilder(
      animation: _diceControllers[dieIndex],
      builder: (context, child) {
        final rotationValue = _diceControllers[dieIndex].value * 2 * math.pi;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(isRolling ? rotationValue : 0)
            ..rotateY(isRolling ? rotationValue * 1.5 : 0)
            ..rotateZ(isRolling ? rotationValue * 0.5 : 0),
          alignment: Alignment.center,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade100,
                  Colors.grey.shade200,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade400, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: -5,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                symbols[symbolIndex]['icon']!,
                style: const TextStyle(
                  fontSize: 48,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBettingGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4A2511).withOpacity(0.6),
            Color(0xFF2C1810).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          int currentBet = bets[index] ?? 0;
          bool hasBet = currentBet > 0;

          return GestureDetector(
            onTap: isRolling ? null : () => _placeBet(index),
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(hasBet ? -0.1 : 0),
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: hasBet
                        ? [
                            Color(0xFFFFD700),
                            Color(0xFFFFA500),
                            Color(0xFFFF8C00),
                          ]
                        : [
                            Color(0xFFD7CCC8),
                            Color(0xFFBCAAA4),
                            Color(0xFFA1887F),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        hasBet ? Colors.amber.shade700 : Colors.brown.shade400,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: hasBet
                          ? Colors.amber.withOpacity(0.6)
                          : Colors.black.withOpacity(0.4),
                      blurRadius: hasBet ? 20 : 10,
                      spreadRadius: hasBet ? 3 : 1,
                      offset: Offset(0, hasBet ? 8 : 5),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: -2,
                      offset: const Offset(-3, -3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        symbols[index]['icon']!,
                        style: const TextStyle(
                          fontSize: 40,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      symbols[index]['kh']!,
                      style: TextStyle(
                        color: hasBet
                            ? Colors.brown.shade900
                            : Colors.brown.shade700,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        shadows: const [
                          Shadow(
                            color: Colors.white24,
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    if (hasBet)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.brown.shade900,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '\$$currentBet',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
              )
                  .animate(target: hasBet ? 1 : 0)
                  .scale(
                      begin: const Offset(1, 1), end: const Offset(1.05, 1.05))
                  .shimmer(
                      duration: 1.seconds,
                      color: Colors.white.withOpacity(0.3)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3E2723),
            Color(0xFF2C1810),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isRolling ? null : _clearBets,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade700,
                foregroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.brown.shade900, width: 2),
                ),
                elevation: 5,
              ),
              child: const Text(
                'លុប',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isRolling ? null : _rollDice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isRolling
                        ? [Colors.grey.shade600, Colors.grey.shade700]
                        : [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: isRolling
                          ? Colors.black26
                          : Colors.amber.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🎲 រំកិល',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.brown,
                          shadows: [
                            Shadow(
                              color: Colors.white24,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
