import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/l10n/app_localizations.dart';

class OrderFilterBar extends StatelessWidget {
  final List<String> statusFilters;
  final String activeFilter;
  final Function(String) onFilterChanged;
  final bool isDark;

  static const Color lazadaOrange = Color(0xFFFF6600);

  const OrderFilterBar({
    super.key,
    required this.statusFilters,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Container(
      height: 48, // Increased height for better touch target
      margin:
          const EdgeInsets.symmetric(vertical: 8), // Reduced vertical margin

      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: statusFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = statusFilters[index];
          final isActive = activeFilter == filter;
          String label = filter == 'All'
              ? t.translate('all')
              : t.translate('order_${filter.toLowerCase()}');

          return GestureDetector(
            onTap: () => onFilterChanged(filter),
            child: AnimatedContainer(
              duration: 250.ms,
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                color: isActive
                    ? lazadaOrange
                    : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: isActive
                      ? Colors.transparent
                      : (isDark ? Colors.white10 : lazadaOrange),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
