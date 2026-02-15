import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/models/product.dart';
import 'package:app1/services/api_service.dart';
import 'package:app1/models/product_variant.dart';
import 'package:app1/features/favorite/logic/favorite_controller.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/store_info_section.dart';
import '../widgets/product_action_bottom_bar.dart';
import '../widgets/recommended_products_section.dart';
import '../widgets/variant_selector_sheet.dart';
import '../widgets/product_detail_header.dart';
import '../widgets/product_detail_info.dart';
import '../widgets/product_detail_variant_section.dart';
import '../widgets/product_detail_description_section.dart';
import '../widgets/product_image_gallery.dart';
import 'package:app1/features/store/presentation/pages/store_profile_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app1/l10n/app_localizations.dart';

class ProductDetailPage extends StatefulWidget {
  final Product initialProduct;

  const ProductDetailPage({super.key, required this.initialProduct});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product product;
  String _description = "Loading description...";
  int _quantity = 1;
  int? _userId;
  ProductVariant? _selectedVariant;
  List<Product> _recommendedProducts = [];
  late FavoriteController _favoriteController;

  @override
  void initState() {
    super.initState();
    _favoriteController = Get.put(FavoriteController());
    product = widget.initialProduct;
    _loadUser();
    _fetchFullDetail();
    _fetchRecommended();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? prefs.getString('userId');
    if (token != null) {
      if (mounted) {
        setState(() {
          _userId = int.tryParse(token);
        });
      }
    }
  }

  Future<void> _fetchFullDetail() async {
    try {
      Product fullDetail = await ApiService.getProductDetail(product.id);
      if (mounted) {
        setState(() {
          product = fullDetail;
          _description = product.description ??
              "This premium product from ${product.store?.name ?? 'our store'} offers exceptional quality and value. Designed with care and crafted from the finest materials.";
          if (product.variants.isNotEmpty && _selectedVariant == null) {
            _selectedVariant = product.variants.first;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _description = "No description available.");
    }
  }

  Future<void> _fetchRecommended() async {
    try {
      final products = await ApiService.fetchProducts(page: 1);
      if (mounted) {
        setState(() {
          _recommendedProducts =
              products.where((p) => p.id != product.id).toList();
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _showVariantSelector({bool isBuyNow = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VariantSelectorSheet(
        product: product,
        initialVariant: _selectedVariant,
        initialQuantity: _quantity,
        onConfirm: (variant, qty) {
          setState(() {
            _selectedVariant = variant;
            _quantity = qty;
          });
          if (isBuyNow) {
            _buyNow();
          } else {
            _addToCart();
          }
        },
      ),
    );
  }

  Future<void> _addToCart() async {
    if (_userId == null) {
      _showToast("Please login to add items to cart", isError: true);
      return;
    }

    try {
      await ApiService.addToCart(_userId!, product.id, _quantity,
          variantId: _selectedVariant?.id);
      if (mounted) {
        _showToast("Successfully added to cart!", isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showToast("Failed to add to cart: $e", isError: true);
      }
    }
  }

  void _buyNow() {
    _showToast("Buy Now process started!", isError: false);
  }

  Future<void> _contactTelegram() async {
    final store = product.store;
    if (store == null || store.telegram == null || store.telegram!.isEmpty) {
      _showToast("Store Telegram not available", isError: true);
      return;
    }

    final telegramUser = store.telegram!.replaceAll('@', '');
    final productUrl = "https://yourapp.com/product/${product.id}";
    final message =
        "Hello, I'm interested in ${product.name} (ID: ${product.id})\nLink: $productUrl";

    final url = Uri.parse(
        "https://t.me/$telegramUser?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _shareProduct() {
    final productUrl = "https://yourapp.com/product/${product.id}";
    Share.share('Check out ${product.name} on Our Store!\n$productUrl');
  }

  void _showToast(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final price = _selectedVariant?.price ?? product.price;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            // Desktop Layout: Side-by-Side
            return Column(
              children: [
                // Top Custom AppBar for Desktop
                _buildDesktopAppBar(context, isDark),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Side: Image Gallery
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: ProductImageGallery(imageUrl: product.image),
                          ),
                        ),
                      ),
                      // Right Side: Details (Scrollable)
                      Expanded(
                        flex: 4,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductDetailInfoSection(
                                stock_main: product.qty,
                                name: product.name,
                                salesCount: product.salesCount,
                                price: price,
                                comparePrice: product.comparePrice,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              if (product.store != null)
                                StoreInfoSection(
                                    store: product.store!, product: product),
                              const SizedBox(height: 16),
                              if (product.variants.isNotEmpty)
                                ProductDetailVariantSection(
                                  attributesSummary:
                                      _selectedVariant?.attributesSummary,
                                  isDark: isDark,
                                  onTap: () => _showVariantSelector(),
                                ),
                              const SizedBox(height: 16),
                              ProductDetailDescriptionSection(
                                description: _description,
                                salesCount: product.salesCount,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 32),
                              RecommendedProductsSection(
                                  products: _recommendedProducts),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Mobile Layout: Stacked with SliverAppBar
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                Obx(() => ProductDetailSliverAppBar(
                      imageUrl: product.image,
                      isDark: isDark,
                      onBack: () => Navigator.pop(context),
                      onShare: _shareProduct,
                      onContact: _contactTelegram,
                      isFavorite: _favoriteController.favorites
                          .any((p) => p.id == product.id),
                      onFavorite: () =>
                          _favoriteController.toggleFavorite(product),
                    )),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductDetailInfoSection(
                          stock_main: product.qty,
                          name: product.name,
                          salesCount: product.salesCount,
                          price: price,
                          comparePrice: product.comparePrice,
                          isDark: isDark,
                        ),
                        if (product.store != null)
                          StoreInfoSection(
                              store: product.store!, product: product),
                        if (product.variants.isNotEmpty)
                          ProductDetailVariantSection(
                            attributesSummary:
                                _selectedVariant?.attributesSummary,
                            isDark: isDark,
                            onTap: () => _showVariantSelector(),
                          ),
                        ProductDetailDescriptionSection(
                          description: _description,
                          salesCount: product.salesCount,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 8),
                        RecommendedProductsSection(
                            products: _recommendedProducts),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: ProductActionBottomBar(
        product: product,
        onAddToCart: () => _showVariantSelector(isBuyNow: false),
        onBuyNow: () => _showVariantSelector(isBuyNow: true),
        onStoreTap: () {
          if (product.store != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoreProfilePage(store: product.store!),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDesktopAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            "Product Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const Spacer(),
          Obx(() {
            final isFavorite =
                _favoriteController.favorites.any((p) => p.id == product.id);
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite
                    ? Colors.red
                    : (isDark ? Colors.white : Colors.black),
              ),
              onPressed: () => _favoriteController.toggleFavorite(product),
            );
          }),
          IconButton(
            icon:
                Icon(Icons.share, color: isDark ? Colors.white : Colors.black),
            onPressed: _shareProduct,
          ),
        ],
      ),
    );
  }
}
