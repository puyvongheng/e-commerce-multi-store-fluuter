import 'package:flutter/material.dart';

class VariantSelectorQuantity extends StatelessWidget {
  final int quantity;
  final int? maxQuantity;
  final bool isDark;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const VariantSelectorQuantity({
    super.key,
    required this.quantity,
    this.maxQuantity,
    required this.isDark,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    // If no stock info (maxQuantity is null), assume unlimited or at least 1.
    final bool canIncrement = maxQuantity == null || quantity < maxQuantity!;
    final bool canDecrement = quantity > 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Quantity",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildQtyBtn(Icons.remove, onDecrement, isEnabled: canDecrement),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "$quantity",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              _buildQtyBtn(Icons.add, onIncrement, isEnabled: canIncrement),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap,
      {required bool isEnabled}) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 20,
          color: isEnabled ? null : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }
}
