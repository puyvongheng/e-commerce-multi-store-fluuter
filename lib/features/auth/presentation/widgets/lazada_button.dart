// lib/features/auth/presentation/widgets/lazada_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LazadaButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;

  const LazadaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
  });

  static const Color lazadaOrange = Color(0xFFFF6600);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : lazadaOrange,
          foregroundColor: isOutlined ? lazadaOrange : Colors.white,
          elevation: isOutlined ? 0 : 4,
          shadowColor: lazadaOrange.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isOutlined
                ? const BorderSide(color: lazadaOrange, width: 2)
                : BorderSide.none,
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? const SpinKitThreeBounce(
                color: Colors.white,
                size: 24,
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
      ),
    );
  }
}
