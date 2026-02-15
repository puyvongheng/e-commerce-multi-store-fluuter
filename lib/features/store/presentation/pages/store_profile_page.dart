import 'package:flutter/material.dart';
import 'package:app1/models/store.dart';
import 'package:app1/models/product.dart';
import 'package:app1/services/api_service.dart';
import 'package:app1/features/product/presentation/widgets/product_card.dart';
import 'package:app1/features/product/presentation/pages/product_detail_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/store_profile_app_bar.dart';
import '../widgets/store_profile_value_props.dart';
import '../widgets/store_profile_pinned_header.dart';
import '../widgets/store_profile_bottom_bar.dart';

class StoreProfilePage extends StatefulWidget {
  final Store store;

  const StoreProfilePage({super.key, required this.store});

  @override
  State<StoreProfilePage> createState() => _StoreProfilePageState();
}

class _StoreProfilePageState extends State<StoreProfilePage> {
  List<Product> _products = [];
  Store? _fullStore;
  bool _isLoading = true;
  bool _isFollowing = false;

  static const Color lazadaOrange = Color(0xFFFF6600);

  @override
  void initState() {
    super.initState();
    _fetchStoreProducts();
    _fetchStoreDetail();
  }

  Future<void> _fetchStoreDetail() async {
    try {
      final detail = await ApiService.getStoreDetail(widget.store.id);
      if (detail != null && mounted) {
        setState(() {
          _fullStore = detail;
        });
      }
    } catch (e) {
      print("Error fetching store detail: $e");
    }
  }

  Future<void> _fetchStoreProducts() async {
    try {
      final products = await ApiService.fetchProducts(storeId: widget.store.id);
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onChatTap() async {
    final store = widget.store;
    if (store.telegram == null || store.telegram!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No contact info available')),
      );
      return;
    }

    final telegramUser = store.telegram!.replaceAll('@', '');
    final message = "Hello, I'm interested in products from ${store.name}";
    final url = Uri.parse(
        "https://t.me/$telegramUser?text=${Uri.encodeComponent(message)}");

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch Telegram')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          StoreProfileSliverAppBar(
            store: _fullStore ?? widget.store,
            isDark: isDark,
            onBack: () => Navigator.pop(context),
            onSearch: () {},
            onMore: () {},
          ),
          SliverToBoxAdapter(
              // child: StoreProfileValueProps(
              //   store: widget.store,
              //   isDark: isDark,
              // ),
              ),
          StoreProfilePinnedHeader(
              isDark: isDark, store: _fullStore ?? widget.store),
          _buildProductGrid(t, isDark),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
      bottomNavigationBar: StoreProfileBottomBar(
        store: _fullStore ?? widget.store,
        isDark: isDark,
        isFollowing: _isFollowing,
        onChatTap: _onChatTap,
        onFollowTap: () => setState(() => _isFollowing = !_isFollowing),
      ),
    );
  }

  Widget _buildProductGrid(AppLocalizations? t, bool isDark) {
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(child: CircularProgressIndicator(color: lazadaOrange)),
        ),
      );
    }

    if (_products.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(t?.translate('no_store_products') ?? 'No products found',
                    style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          ),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16),
      sliver: isMobile
          ? SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              itemBuilder: (context, index) => ProductCard(
                product: _products[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailPage(initialProduct: _products[index]),
                    ),
                  );
                },
                onAddTap: () {},
              ).animate().fadeIn(delay: (index * 50).ms),
              childCount: _products.length,
            )
          : SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ProductCard(
                    product: _products[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(
                              initialProduct: _products[index]),
                        ),
                      );
                    },
                    onAddTap: () {},
                  ).animate().fadeIn(delay: (index * 50).ms);
                },
                childCount: _products.length,
              ),
            ),
    );
  }
}
