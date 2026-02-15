import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/services/cart_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app1/features/cart/presentation/pages/checkout_page.dart';
import '../widgets/empty_cart_view.dart';
import '../widgets/cart_summary_bar.dart';
import '../widgets/cart_sliver_app_bar.dart';
import '../widgets/cart_store_section.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isLoading = true;
  List<dynamic> _cartItems = [];
  int? _userId;
  final Set<int> _selectedItemIds = {};

  static const Color lazadaOrange = Color(0xFFFF6600);

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    String? userIdStr = prefs.getString('userId') ?? prefs.getString('token');

    if (userIdStr != null) {
      _userId = int.tryParse(userIdStr);
    }

    if (_userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await CartService.getCart(_userId!);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (mounted) {
          setState(() {
            var items =
                data['CartItems'] ?? data['cartItems'] ?? data['items'] ?? [];
            _cartItems = items;
            // Initially select all if not already managing selection
            if (_selectedItemIds.isEmpty) {
              for (var item in _cartItems) {
                if (item['id'] != null) _selectedItemIds.add(item['id']);
              }
            }
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading cart: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToCheckout() {
    if (_userId == null) return;
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select items to checkout")));
      return;
    }

    final selectedItems = _cartItems
        .where((item) => _selectedItemIds.contains(item['id']))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          selectedItems: selectedItems,
          userId: _userId!,
        ),
      ),
    ).then((_) => _loadCart());
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in _cartItems) {
      if (!_selectedItemIds.contains(item['id'])) continue;
      final productData = item['Product'] ?? item['product'];
      final quantity = item['quantity'] ?? 0;
      if (productData != null) {
        final double price =
            double.tryParse(productData['price'].toString()) ?? 0.0;
        total += price * (quantity as int);
      }
    }
    return total;
  }

  Map<String, List<dynamic>> _groupItemsByStore() {
    Map<String, List<dynamic>> groupedResponse = {};
    for (var item in _cartItems) {
      final product = item['Product'] ?? item['product'];
      if (product == null) continue;
      final store = product['Store'] ?? product['store'];
      final storeName = store != null ? store['name'] : "Store";
      if (!groupedResponse.containsKey(storeName)) {
        groupedResponse[storeName] = [];
      }
      groupedResponse[storeName]!.add(item);
    }
    return groupedResponse;
  }

  void _toggleAll(bool? value) {
    setState(() {
      if (value == true) {
        for (var item in _cartItems) {
          if (item['id'] != null) _selectedItemIds.add(item['id']);
        }
      } else {
        _selectedItemIds.clear();
      }
    });
  }

  void _toggleStore(List<dynamic> items, bool? value) {
    setState(() {
      if (value == true) {
        for (var item in items) {
          if (item['id'] != null) _selectedItemIds.add(item['id']);
        }
      } else {
        for (var item in items) {
          if (item['id'] != null) _selectedItemIds.remove(item['id']);
        }
      }
    });
  }

  Future<void> _updateQuantity(dynamic item, int change) async {
    if (_userId == null) return;
    final productData = item['Product'] ?? item['product'];
    final productId = productData['id'];
    final variantId = item['productVariantId'];
    try {
      await CartService.addToCart(_userId!, productId, change,
          variantId: variantId);
      _loadCart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _removeItem(dynamic item) async {
    if (_userId == null) return;
    final productData = item['Product'] ?? item['product'];
    final productId = productData['id'];
    final variantId = item['productVariantId'];
    try {
      await CartService.deleteFromCart(_userId!, productId,
          variantId: variantId);
      _loadCart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupedItems = _groupItemsByStore();
    final allSelected =
        _cartItems.isNotEmpty && _selectedItemIds.length == _cartItems.length;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F8FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: lazadaOrange))
          : _cartItems.isEmpty
              ? const EmptyCartView()
              : Stack(
                  children: [
                    CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        CartSliverAppBar(
                          allSelected: allSelected,
                          hasItems: _cartItems.isNotEmpty,
                          isDark: isDark,
                          onToggleAll: () => _toggleAll(!allSelected),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 200),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                String storeName =
                                    groupedItems.keys.elementAt(index);
                                List<dynamic> storeItems =
                                    groupedItems[storeName]!;
                                bool isStoreSelected = storeItems.every(
                                    (item) =>
                                        _selectedItemIds.contains(item['id']));

                                return CartStoreSection(
                                  storeName: storeName,
                                  storeItems: storeItems,
                                  isStoreSelected: isStoreSelected,
                                  isDark: isDark,
                                  onToggleStore: (val) =>
                                      _toggleStore(storeItems, val),
                                  selectedItemIds: _selectedItemIds,
                                  onToggleItem: (itemId, val) => setState(() {
                                    if (val == true)
                                      _selectedItemIds.add(itemId);
                                    else
                                      _selectedItemIds.remove(itemId);
                                  }),
                                  onUpdateQuantity: _updateQuantity,
                                  onRemoveItem: _removeItem,
                                ).animate().fadeIn(delay: (index * 80).ms);
                              },
                              childCount: groupedItems.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: CartSummaryBar(
                        total: _calculateTotal(),
                        itemCount: _selectedItemIds.length,
                        onCheckout: _selectedItemIds.isEmpty
                            ? null
                            : _navigateToCheckout,
                      ).animate().slideY(begin: 1, end: 0, duration: 400.ms),
                    ),
                  ],
                ),
    );
  }
}
