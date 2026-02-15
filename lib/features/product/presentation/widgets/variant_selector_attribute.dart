import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VariantSelectorAttribute extends StatelessWidget {
  final String name;
  final Set<String> options;
  final String? selectedValue;
  final bool isDark;
  final Function(String) onSelected;

  const VariantSelectorAttribute({
    super.key,
    required this.name,
    required this.options,
    this.selectedValue,
    required this.isDark,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const Color lazadaOrange = Color(0xFFFF6600);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            name,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((opt) {
            final isSelected = selectedValue == opt;
            return InkWell(
              onTap: () => onSelected(opt),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: 200.ms,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? lazadaOrange.withOpacity(0.1)
                      : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]),
                  border: Border.all(
                    color: isSelected ? lazadaOrange : Colors.transparent,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    color: isSelected
                        ? lazadaOrange
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
