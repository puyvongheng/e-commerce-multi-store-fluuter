import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app1/services/order_service.dart';
import 'package:app1/models/order.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/l10n/app_localizations.dart';
import 'package:app1/features/order/presentation/widgets/order_filter_bar.dart';
import 'package:app1/features/order/presentation/widgets/order_card.dart';
import 'package:app1/features/order/presentation/widgets/order_empty_state.dart';
import 'package:app1/features/order/presentation/widgets/order_shimmer_loading.dart';
import 'package:app1/features/order/presentation/widgets/order_sliver_app_bar.dart';

class OrdersPage extends StatefulWidget {
  final String? initialFilter;

  const OrdersPage({
    super.key,
    this.initialFilter,
  });

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  bool _isLoading = true;
  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  int? _userId;
  late String _activeFilter;

  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  static const Color backgroundColor = Color(0xFFF8F8FA);

  @override
  void initState() {
    super.initState();
    // Initialize filter from widget parameter or default to 'All'
    _activeFilter = widget.initialFilter ?? 'All';
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    String? userIdStr = prefs.getString('userId');
    if (userIdStr == null && prefs.getString('token') != null) {
      userIdStr = prefs.getString('token');
    }

    if (userIdStr != null) {
      _userId = int.tryParse(userIdStr);
    }

    if (_userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await OrderService.getOrders(_userId!);
      if (mounted) {
        setState(() {
          _allOrders = data.map((json) => Order.fromJson(json)).toList();
          _allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _applyFilter(_activeFilter);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading orders: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter(String status) {
    setState(() {
      _activeFilter = status;
      if (status == 'All') {
        _filteredOrders = _allOrders;
      } else {
        _filteredOrders = _allOrders
            .where((o) => o.status?.toLowerCase() == status.toLowerCase())
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            OrderSliverAppBar(isDark: isDark),
            SliverPersistentHeader(
              delegate: _StickyFilterDelegate(
                child: Container(
                  color: isDark ? const Color(0xFF121212) : backgroundColor,
                  child: OrderFilterBar(
                    statusFilters: _statusFilters,
                    activeFilter: _activeFilter,
                    onFilterChanged: _applyFilter,
                    isDark: isDark,
                  ),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: _isLoading
            ? const Center(
                child:
                    OrderShimmerLoading()) // Changed from SliverFillRemaining to Center as it is in body
            : _filteredOrders.isEmpty
                ? const OrderEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      return OrderCard(
                        order: _filteredOrders[index],
                        isDark: isDark,
                      ).animate().fadeIn(delay: (index * 50).ms).slideY(
                          begin: 0.1, end: 0, curve: Curves.easeOutQuad);
                    },
                  ),
      ),
    );
  }
}

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyFilterDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
