import 'package:flutter/material.dart';
import 'package:app1/models/address.dart';
import 'package:app1/l10n/app_localizations.dart';

class CheckoutAddressSection extends StatelessWidget {
  final Address? selectedAddress;
  final VoidCallback onTap;
  final bool isDark;

  const CheckoutAddressSection({
    super.key,
    required this.selectedAddress,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white10
                : const Color.fromARGB(255, 97, 97, 97).withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1), // Condensed Milk
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF4E342E), // Coffee Brown
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: selectedAddress == null
                  ? Text(
                      t.translate('set_address'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${selectedAddress!.fullName} | ${selectedAddress!.phone}",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${selectedAddress!.addressLine1}, ${selectedAddress!.city}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
