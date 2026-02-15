import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';

class KhmerEmpireGamePage extends StatefulWidget {
  const KhmerEmpireGamePage({super.key});

  @override
  State<KhmerEmpireGamePage> createState() => _KhmerEmpireGamePageState();
}

class _KhmerEmpireGamePageState extends State<KhmerEmpireGamePage> {
  // Resources
  int rice = 100;
  int stone = 50;
  int gold = 20;
  int population = 10;
  int maxPopulation = 20;

  // Building Levels
  int riceFieldLevel = 1;
  int quarryLevel = 0;
  int marketLevel = 0;
  int templeLevel = 0;

  late Timer resourceTimer;
  String lastEvent = "Welcome, Great King! 🇰🇭";

  @override
  void initState() {
    super.initState();
    _startResourceProduction();
  }

  void _startResourceProduction() {
    resourceTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        // Production logic
        rice += riceFieldLevel * 5;
        stone += quarryLevel * 3;
        gold += marketLevel * 2;

        // Consumption
        rice -= (population / 2).ceil();
        if (rice < 0) {
          rice = 0;
          if (population > 5) population--; // Starvation
          lastEvent = "Shortage of rice! Population is decreasing. ⚠️";
        }
      });
    });
  }

  @override
  void dispose() {
    resourceTimer.cancel();
    super.dispose();
  }

  void _buildOrUpgrade(String building) {
    setState(() {
      switch (building) {
        case 'Rice Field':
          if (stone >= 10 && gold >= 5) {
            stone -= 10;
            gold -= 5;
            riceFieldLevel++;
            lastEvent = "Expanded rice fields! 🌾";
          }
          break;
        case 'Quarry':
          int costStone = 20 + (quarryLevel * 10);
          if (rice >= 30 && gold >= 10) {
            rice -= 30;
            gold -= 10;
            quarryLevel++;
            lastEvent = "Opened new stone quarry. 🪨";
          }
          break;
        case 'Market':
          if (stone >= 30 && rice >= 50) {
            stone -= 30;
            rice -= 50;
            marketLevel++;
            lastEvent = "The market is thriving! 💰";
          }
          break;
        case 'Temple':
          int costStone = 50 + (templeLevel * 50);
          int costGold = 20 + (templeLevel * 20);
          if (stone >= costStone && gold >= costGold) {
            stone -= costStone;
            gold -= costGold;
            templeLevel++;
            maxPopulation += 10;
            population += 5; // New people come for the temple
            lastEvent = "Great temple built! 🛕 The gods are pleased.";
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('KHMER EMPIRE',
            style: TextStyle(
                fontWeight: FontWeight.w900, color: Colors.orangeAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTopStats(),
          _buildEventLog(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildBuildingCard(
                      'Rice Field 🌾',
                      riceFieldLevel,
                      'Produces Rice (ស្រូវ)',
                      'Cost: 10 Stone, 5 Gold',
                      () => _buildOrUpgrade('Rice Field')),
                  _buildBuildingCard(
                      'Quarry 🪨',
                      quarryLevel,
                      'Produces Stone (ថ្ម)',
                      'Cost: 30 Rice, 10 Gold',
                      () => _buildOrUpgrade('Quarry')),
                  _buildBuildingCard(
                      'Market 💰',
                      marketLevel,
                      'Produces Gold (មាស)',
                      'Cost: 50 Rice, 30 Stone',
                      () => _buildOrUpgrade('Market')),
                  _buildBuildingCard(
                      'Angkor Temple 🛕',
                      templeLevel,
                      'High Pop Capacity',
                      'Cost: ${50 + (templeLevel * 50)} Stone, ${20 + (templeLevel * 20)} Gold',
                      () => _buildOrUpgrade('Temple')),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildTopStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.black26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('🌾', rice, 'Rice'),
          _statItem('🪨', stone, 'Stone'),
          _statItem('💰', gold, 'Gold'),
          _statItem('👥', population, '$population/$maxPopulation'),
        ],
      ),
    );
  }

  Widget _statItem(String icon, int value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        Text('$value',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildEventLog() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.1),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        lastEvent,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.orangeAccent, fontStyle: FontStyle.italic),
      ).animate(key: ValueKey(lastEvent)).fadeIn().slideX(begin: 0.1, end: 0),
    );
  }

  Widget _buildBuildingCard(String title, int level, String effect, String cost,
      VoidCallback onBuild) {
    bool isLocked = level == 0 && title.contains('Temple') && quarryLevel < 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text('Level: $level',
                    style: const TextStyle(
                        color: Colors.orangeAccent, fontSize: 14)),
                const SizedBox(height: 4),
                Text(effect,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
                Text(cost,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isLocked ? null : onBuild,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(level == 0 ? 'BUILD' : 'UPGRADE'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Text(
        'Strategy: Balance your production! 🌾🪨💰\nBuild temples to grow your empire.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white38, fontSize: 12),
      ),
    );
  }
}
