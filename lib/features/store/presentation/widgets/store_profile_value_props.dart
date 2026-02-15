import 'package:flutter/material.dart';
import 'package:app1/models/store.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/l10n/app_localizations.dart';

class StoreProfileValueProps extends StatelessWidget {
  final Store store;
  final bool isDark;

  const StoreProfileValueProps({
    super.key,
    required this.store,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const Color lazadaOrange = Color(0xFFFF6600);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.translate('about_store'),
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            store.description ??
                "Welcome to ${store.name}! We provide high quality products with fast shipping.",
            style:
                TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPropItem(
                  Icons.local_shipping_outlined, "Fast Delivery", Colors.blue),
              _buildPropItem(
                  Icons.verified_user_outlined, "100% Authentic", Colors.green),
              _buildPropItem(Icons.chat_bubble_outline_rounded, "Chat Support",
                  lazadaOrange),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildPropItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
