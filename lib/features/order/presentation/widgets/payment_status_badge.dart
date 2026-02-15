import 'package:flutter/material.dart';

class PaymentStatusBadge extends StatelessWidget {
  final String status;

  const PaymentStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'paid':
        color = const Color(0xFFE9B306);
        icon = Icons.access_time_filled_rounded;
        label = 'PAID';
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.access_time_rounded;
        label = 'PENDING';
        break;
      case 'failed':
        color = Colors.red;
        icon = Icons.error_outline_rounded;
        label = 'FAILED';
        break;
      case 'refunded':
        color = Colors.purple;
        icon = Icons.undo_rounded;
        label = 'REFUNDED';
        break;
      case 'cancelled':
        color = Colors.grey;
        icon = Icons.cancel_outlined;
        label = 'CANCELLED';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline_rounded;
        label = status.toUpperCase();
    }

    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
