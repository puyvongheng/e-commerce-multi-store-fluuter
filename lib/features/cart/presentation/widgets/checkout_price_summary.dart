import 'package:flutter/material.dart';
import 'package:app1/l10n/app_localizations.dart';

class CheckoutPriceSummary extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double discount;
  final double total;
  final bool isDark;

  const CheckoutPriceSummary({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const Color lazadaOrange = Color(0xFFFF6600);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? Colors.white10
        : const Color.fromARGB(255, 107, 107, 107).withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _summaryRow(
            t.translate('subtotal'),
            "\$${subtotal.toStringAsFixed(2)}",
            false,
            isDark,
          ),
          const SizedBox(height: 12),
          _summaryRow(
            t.translate('shipping_fee'),
            "\$${shipping.toStringAsFixed(2)}",
            false,
            isDark,
          ),
          if (discount > 0) ...[
            const SizedBox(height: 12),
            _summaryRow(
              "Discount",
              "-\$${discount.toStringAsFixed(2)}",
              false,
              isDark,
              color: Colors.redAccent,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              height: 1,
              thickness: 1,
              color: isDark ? Colors.white10 : Colors.grey[100],
            ),
          ),
          _summaryRow(
            t.translate('total_amount'),
            "\$${total.toStringAsFixed(2)}",
            true,
            isDark,
            color: lazadaOrange,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isBold, bool isDark,
      {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold
                ? (isDark ? Colors.white : Colors.black87)
                : Colors.grey[600],
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: isBold ? 20 : 15,
            color: color ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}
