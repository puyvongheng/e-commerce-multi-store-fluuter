import 'package:app1/models/store.dart';
import 'package:flutter/material.dart';
import 'package:app1/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreProfilePinnedHeader extends StatelessWidget {
  final bool isDark;
  final Store store;

  const StoreProfilePinnedHeader({
    super.key,
    required this.isDark,
    required this.store,
  });

  Future<void> _openMap() async {
    if (store.lat != null && store.lng != null) {
      final googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=${store.lat},${store.lng}";
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl),
            mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const Color lazadaOrange = Color(0xFFFF6600);

    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverHeaderDelegate(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: isDark ? const Color(0xFF121212) : const Color(0xFFF1F5F9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.grid_view_rounded,
                      color: lazadaOrange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    t.translate('store_products'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (store.lat != null && store.lng != null)
                    InkWell(
                      onTap: _openMap,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.green.withOpacity(0.5)),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              "Map",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.map_outlined,
                                size: 16, color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          t.translate('all'),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.filter_list_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverHeaderDelegate({required this.child});
  @override
  double get minExtent => 50;
  @override
  double get maxExtent => 50;
  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;
  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) => false;
}
