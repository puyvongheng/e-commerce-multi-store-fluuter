import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchRecentList extends StatelessWidget {
  final List<String> recentSearches;
  final Function(String) onSearchTap;
  final bool isDark;

  const SearchRecentList({
    super.key,
    required this.recentSearches,
    required this.onSearchTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "Recent Searches",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: recentSearches.map((search) {
            return GestureDetector(
              onTap: () => onSearchTap(search),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                ),
                child: Text(
                  search,
                  style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 14),
                ),
              ),
            );
          }).toList(),
        ).animate().fadeIn(duration: 400.ms),
      ],
    );
  }
}
