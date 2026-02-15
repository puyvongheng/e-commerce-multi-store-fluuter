// lib/features/auth/presentation/widgets/lazada_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LazadaTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;

  const LazadaTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<LazadaTextField> createState() => _LazadaTextFieldState();
}

class _LazadaTextFieldState extends State<LazadaTextField> {
  bool _isObscured = true;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF2A2A2A),
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
          },
          child: AnimatedContainer(
            duration: 300.ms,
            curve: Curves.easeOutCubic,
            child: TextField(
              controller: widget.controller,
              obscureText: widget.obscureText && _isObscured,
              keyboardType: widget.keyboardType,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF2A2A2A),
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  widget.icon,
                  color: _isFocused
                      ? const Color(0xFFFF6600)
                      : (isDark ? Colors.grey[600] : Colors.grey[400]),
                  size: 22,
                ),
                suffixIcon: widget.obscureText
                    ? IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility_off : Icons.visibility,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() => _isObscured = !_isObscured);
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }
}
