import 'package:flutter/material.dart';
import 'package:app1/models/payment_method.dart';

class CheckoutPaymentSelector extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final String selectedPaymentMethod;
  final Function(String) onChanged;
  final bool isDark;

  const CheckoutPaymentSelector({
    super.key,
    required this.paymentMethods,
    required this.selectedPaymentMethod,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const Color lazadaOrange = Color(0xFFFF6600);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? Colors.white10
        : const Color.fromARGB(255, 119, 119, 119).withOpacity(0.1);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: paymentMethods.map((method) {
          final isSelected = selectedPaymentMethod == method.id;
          final isKHQR = method.id.toLowerCase().contains('khqr');

          return InkWell(
            onTap: () => onChanged(method.id),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getColor(method.color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(method.icon),
                      color: _getColor(method.color),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              method.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (isKHQR) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "FAST",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (method.description != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              method.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: lazadaOrange,
                          size: 24,
                        )
                      : Icon(
                          Icons.radio_button_off_rounded,
                          color: Colors.grey[300],
                          size: 24,
                        ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'money_off_rounded':
        return Icons.money_off_rounded;
      case 'account_balance_rounded':
        return Icons.account_balance_rounded;
      case 'wallet_rounded':
        return Icons.wallet_rounded;
      case 'credit_card_rounded':
        return Icons.credit_card_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue[900]!;
      case 'lightGreen':
        return Colors.lightGreen;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
