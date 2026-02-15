import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onScanTap;

  final bool readOnly;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.onTap,
    this.onChanged,
    this.onScanTap,
    this.readOnly = false,
  });

  static const Color lazadaOrange = Color(0xFFFF6600);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          // Input Field
          Expanded(
            child: TextField(
              readOnly: readOnly,
              controller: controller,
              onTap: onTap,
              onChanged: onChanged,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // Action Buttons (Clear)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: Colors.grey),
                onPressed: () {
                  controller.clear();
                  if (onChanged != null) onChanged!('');
                },
              );
            },
          ),

          // Scan Button
          if (onScanTap != null)
            IconButton(
              onPressed: onScanTap,
              icon: const Icon(Icons.qr_code_scanner_rounded,
                  color: Colors.grey, size: 20),
              tooltip: 'Scan QR',
            ),

          const SizedBox(width: 4),

          // Colored Search Button on the Right
          GestureDetector(
            onTap: () {
              // Trigger search logic if provided, or just let TextField handle it via keyboard
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: lazadaOrange,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: lazadaOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}
