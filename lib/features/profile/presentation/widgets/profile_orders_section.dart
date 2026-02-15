import 'package:app1/features/order/presentation/pages/orders_page.dart';
import 'package:app1/features/profile/presentation/widgets/profile_menu_icon.dart';
import 'package:app1/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileOrdersSection extends StatelessWidget {
  const ProfileOrdersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.translate('my_orders'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToOrders(context, 'All'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        t.translate('all'),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ProfileMenuIcon(
                svgPath: 'assets/icons/pending_icon.svg',
                label: t.translate('pending'),
                // color: Colors.orange, // keeping original SVG color
                onTap: () => _navigateToOrders(context, 'Pending'),
              ),
              SizedBox(width: 10),
              ProfileMenuIcon(
                icon: Icons.inventory_2_rounded,
                label: t.translate('processing'),
                color: Colors.blue,
                onTap: () => _navigateToOrders(context, 'Processing'),
              ),
              SizedBox(width: 10),
              ProfileMenuIcon(
                svgPath: 'assets/icons/shipping_icon.svg',
                label: t.translate('shipped'),
                // color: Colors.indigo, // keeping original SVG color
                onTap: () => _navigateToOrders(context, 'Shipped'),
              ),

              // SizedBox(width: 10),

              // ProfileMenuIcon(
              //   icon: Icons.check_circle_rounded,
              //   label: t.translate('delivered'),
              //   color: Colors.green,
              //   onTap: () => _navigateToOrders(context, 'Delivered'),
              // ),

              SizedBox(width: 10),

              ProfileMenuIcon(
                icon: Icons.check_circle_rounded,
                label: t.translate('completed'),
                color: Colors.green,
                onTap: () => _navigateToOrders(context, 'Completed'),
              ),
              // ProfileMenuIcon(
              //   icon: Icons.check_circle_rounded,
              //   label: t.translate('all'),
              //   color: Colors.green,
              //   onTap: () => _navigateToOrders(context, 'All'),
              // ),
              // SizedBox(width: 10),

              // ProfileMenuIcon(
              //   icon: Icons.rate_review_rounded,
              //   label: t.translate('reviews'),
              //   color: Colors.amber,
              //   onTap: () => _navigateToOrders(context, 'Delivered'),
              // ),
            ],
          )
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  void _navigateToOrders(BuildContext context, String status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrdersPage(initialFilter: status),
      ),
    );
  }
}
