import 'package:app1/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ProfileRecommendedTitle extends StatelessWidget {
  const ProfileRecommendedTitle({super.key});

  static const Color lazadaOrange = Color(0xFFFF6600);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 30, height: 1, color: Colors.grey[300]),
          const SizedBox(width: 10),
          const Icon(Icons.star_rounded, color: lazadaOrange, size: 18),
          const SizedBox(width: 8),
          Text(
            t.translate('featured_products'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 30, height: 1, color: Colors.grey[300]),
        ],
      ),
    );
  }
}
