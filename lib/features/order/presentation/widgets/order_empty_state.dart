import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/l10n/app_localizations.dart';

class OrderEmptyState extends StatelessWidget {
  static const Color lazadaOrange = Color(0xFFFF6600);

  const OrderEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: lazadaOrange.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_rounded,
                size: 100, color: lazadaOrange.withOpacity(0.5)),
          ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 32),
          Text(
            t.translate('no_orders_found'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              "Start your shopping journey today and your orders will appear here!",
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.grey[500], fontSize: 15, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
