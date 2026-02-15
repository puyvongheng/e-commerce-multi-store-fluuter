import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/models/store.dart';
import 'package:app1/features/store/presentation/pages/store_profile_page.dart';
import 'cart_item_tile.dart';

class CartStoreSection extends StatelessWidget {
  final String storeName;
  final List<dynamic> storeItems;
  final bool isStoreSelected;
  final bool isDark;
  final Function(bool?) onToggleStore;
  final Set<int> selectedItemIds;
  final Function(int, bool?) onToggleItem;
  final Function(dynamic, int) onUpdateQuantity;
  final Function(dynamic) onRemoveItem;

  static const Color lazadaOrange = Color(0xFFFF6600);

  const CartStoreSection({
    super.key,
    required this.storeName,
    required this.storeItems,
    required this.isStoreSelected,
    required this.isDark,
    required this.onToggleStore,
    required this.selectedItemIds,
    required this.onToggleItem,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Store Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(
              children: [
                // Selection Checkbox (Store Level1)
                Transform.scale(
                  scale: 0.9,
                  child: Checkbox(
                    value: isStoreSelected,
                    activeColor: lazadaOrange,
                    side: BorderSide(
                      color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onChanged: onToggleStore,
                  ),
                ),

                // Store Info (Clickable for Store Profile)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (storeItems.isNotEmpty) {
                        final productData = storeItems.first['Product'] ??
                            storeItems.first['product'];
                        final storeData =
                            productData?['Store'] ?? productData?['store'];
                        if (storeData != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoreProfilePage(
                                store: Store.fromJson(storeData),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // Store Icon with Creamy Background
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1), // Condensed Milk
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              size: 16,
                              color: Color(0xFF4E342E), // Coffee Brown
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Store Name
                          Expanded(
                            child: Text(
                              storeName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black87,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Navigation Indicator
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: storeItems.length,
            separatorBuilder: (c, i) =>
                const Divider(height: 0.01, thickness: 0.01),
            itemBuilder: (context, i) {
              final item = storeItems[i];
              final int itemId = item['id'] ?? 0;
              return CartItemTile(
                item: item,
                isSelected: selectedItemIds.contains(itemId),
                onToggle: (val) => onToggleItem(itemId, val),
                onUpdateQuantity: (change) => onUpdateQuantity(item, change),
                onRemove: () => onRemoveItem(item),
              );
            },
          ),
        ],
      ),
    ).animate().moveY(begin: 20, end: 0, duration: 400.ms).fadeIn();
  }
}
