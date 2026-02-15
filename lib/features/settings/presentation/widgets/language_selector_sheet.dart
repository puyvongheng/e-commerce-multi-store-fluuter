import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LanguageSelectorSheet extends StatelessWidget {
  final Function(String) onLanguageChange;

  const LanguageSelectorSheet({super.key, required this.onLanguageChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2026) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            "Select Language",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),

          _buildLangItem(context, "English (US)", "en", "🇺🇸",
              currentLocale == "en", isDark),
          const SizedBox(height: 12),
          _buildLangItem(context, "Khmer (ភាសាខ្មែរ)", "km", "🇰🇭",
              currentLocale == "km", isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLangItem(BuildContext context, String label, String code,
      String flag, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () {
        onLanguageChange(code);
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF6600).withOpacity(0.1)
              : (isDark ? const Color(0xFF2A2C32) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6600) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                      color: Color(0xFFFF6600), size: 24)
                  .animate()
                  .scale(duration: 200.ms, curve: Curves.easeOutBack),
          ],
        ),
      ),
    );
  }
}
