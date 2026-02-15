// lib/features/auth/presentation/widgets/lazada_auth_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LazadaAuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const LazadaAuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  static const Color lazadaOrange = Color(0xFFFF6600);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Lazada-style logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [lazadaOrange, Color(0xFFFF8833)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: lazadaOrange.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.shopping_bag,
            size: 40,
            color: Colors.white,
          ),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .rotate(begin: -0.1, end: 0),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A2A2A),
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.5, end: 0, curve: Curves.easeOutQuad),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 400.ms)
            .slideY(begin: 0.5, end: 0, curve: Curves.easeOutQuad),
      ],
    );
  }
}
