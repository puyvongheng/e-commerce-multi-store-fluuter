import 'package:app1/features/profile/presentation/pages/wishlist_page.dart';
import 'package:app1/features/profile/presentation/widgets/profile_menu_icon.dart';
import 'package:app1/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileToolsGrid extends StatelessWidget {
  const ProfileToolsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 20,
            alignment: WrapAlignment.spaceAround,
            children: [
              ProfileMenuIcon(
                  icon: Icons.confirmation_num_rounded,
                  label: t.translate('coupons'),
                  color: Colors.red),
              ProfileMenuIcon(
                  icon: Icons.favorite_rounded,
                  label: t.translate('wishlist'),
                  color: Colors.pink,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const WishlistPage()))),
              ProfileMenuIcon(
                  icon: Icons.person_add_rounded,
                  label: t.translate('following'),
                  color: Colors.blue),
              ProfileMenuIcon(
                  icon: Icons.history_rounded,
                  label: t.translate('history'),
                  color: Colors.teal),
              ProfileMenuIcon(
                  icon: Icons.assignment_return_rounded,
                  label: t.translate('refunds'),
                  color: Colors.brown),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
