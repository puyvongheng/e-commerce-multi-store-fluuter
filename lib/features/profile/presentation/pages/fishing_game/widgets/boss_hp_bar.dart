import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/boss_fish.dart';

class BossHPBar extends StatelessWidget {
  final BossFish boss;

  const BossHPBar({
    super.key,
    required this.boss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 160,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: boss.isEnraged
                ? [Colors.red.shade900, Colors.red.shade700]
                : [Colors.purple.shade900, Colors.purple.shade700],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: boss.isEnraged ? Colors.red : Colors.purple,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: (boss.isEnraged ? Colors.red : Colors.purple)
                  .withOpacity(0.8),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  boss.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            boss.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          if (boss.isEnraged) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ENRAGED',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                                .animate(
                                    onPlay: (controller) => controller.repeat())
                                .shimmer(duration: 500.ms),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${boss.hp} / ${boss.maxHp} HP',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: boss.hpPercentage,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: boss.hpPercentage > 0.5
                          ? [Colors.green, Colors.lightGreen]
                          : boss.hpPercentage > 0.3
                              ? [Colors.orange, Colors.deepOrange]
                              : [Colors.red, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: (boss.hpPercentage > 0.5
                                ? Colors.green
                                : boss.hpPercentage > 0.3
                                    ? Colors.orange
                                    : Colors.red)
                            .withOpacity(0.8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.5, end: 0);
  }
}
