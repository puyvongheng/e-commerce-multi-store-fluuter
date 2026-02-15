import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/l10n/app_localizations.dart';

class ProductDetailVariantSection extends StatelessWidget {
  final String? attributesSummary;
  final bool isDark;
  final VoidCallback onTap;

  const ProductDetailVariantSection({
    super.key,
    required this.attributesSummary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const Color lazadaOrange = Color(0xFFFF6600);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        child: Row(
          children: [
            Text(
              t.translate('select_variation'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Text(
              attributesSummary ?? t.translate('choose_option'),
              style: TextStyle(
                  color: isDark ? Colors.orange[300] : lazadaOrange,
                  fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}
