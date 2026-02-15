import 'package:flutter/material.dart';
import 'package:app1/l10n/app_localizations.dart';

class CartSliverAppBar extends StatelessWidget {
  final bool allSelected;
  final bool hasItems;
  final bool isDark;
  final VoidCallback onToggleAll;

  static const Color lazadaOrange = Color(0xFFFF6600);

  const CartSliverAppBar({
    super.key,
    required this.allSelected,
    required this.hasItems,
    required this.isDark,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        t.translate('cart'),
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 20,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        if (hasItems)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: onToggleAll,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                allSelected
                    ? t.translate('unselect')
                    : t.translate('select_all'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF993D00), const Color(0xFFCC5200)]
                : [lazadaOrange, const Color(0xFFFF8C42)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
