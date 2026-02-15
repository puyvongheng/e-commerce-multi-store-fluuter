import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ComboDisplay extends StatelessWidget {
  final int comboCount;
  final double multiplier;

  const ComboDisplay({
    super.key,
    required this.comboCount,
    required this.multiplier,
  });

  @override
  Widget build(BuildContext context) {
    if (comboCount < 2) return const SizedBox.shrink();

    return Positioned(
      top: 200,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getComboColors(),
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: _getComboColors().first.withOpacity(0.8),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'COMBO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'x$comboCount',
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${multiplier}x',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: _getComboColors().first,
                      ),
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
        .scale(
            duration: 500.ms,
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1))
        .shimmer(duration: 1.seconds, color: Colors.white.withOpacity(0.5));
  }

  List<Color> _getComboColors() {
    if (comboCount >= 20) {
      return [Colors.purple, Colors.pink];
    } else if (comboCount >= 10) {
      return [Colors.red, Colors.orange];
    } else if (comboCount >= 5) {
      return [Colors.orange, Colors.yellow];
    } else {
      return [Colors.green, Colors.lightGreen];
    }
  }
}
