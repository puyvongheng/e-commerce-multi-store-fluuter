import 'package:flutter/material.dart';
import 'package:app1/services/product_service.dart';
import 'package:app1/models/product.dart';
import 'package:app1/models/category.dart';
import 'package:app1/models/slide.dart'; // Import Slide
import 'package:app1/features/product/presentation/widgets/product_card.dart';
import 'package:app1/features/product/presentation/pages/product_detail_page.dart';
import '../widgets/image_carousel.dart';
import '../widgets/lazada_app_bar.dart';
import '../widgets/flash_sale_banner.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/category_section.dart';
import 'package:app1/l10n/app_localizations.dart';
import '../widgets/section_header.dart';
import '../widgets/example_products.dart';
import 'package:app1/features/search/presentation/pages/search_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:app1/features/home/presentation/widgets/quick_access_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Category> _categories = [];
  List<Slide> _slides = []; // Add slides list
  int _page = 1;
  bool _isLoadingFirst = true;
  bool _isLoadMoreRunning = false;
  bool _hasNextPage = true;

  static const Color lazadaOrange = Color(0xFFFF6600);

  // Removed _carouselImages as we fetch from API

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
    _fetchCategories();
    _fetchSlides(); // Fetch slides
    _scrollController.addListener(_loadMoreProducts);
  }

  Future<void> _fetchCategories() async {
    try {
      final result = await ProductService.getCategories();
      if (mounted) {
        setState(() => _categories = result['categories'] as List<Category>);
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

  Future<void> _fetchSlides() async {
    try {
      final slides = await ProductService.fetchSlides();
      if (mounted) setState(() => _slides = slides);
    } catch (e) {
      debugPrint("Error fetching slides: $e");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFirstPage() async {
    try {
      final products = await ProductService.fetchProducts(page: 1);
      if (mounted) {
        setState(() {
          _products =
              products.isEmpty ? ExampleProducts.getSampleProducts() : products;
          _isLoadingFirst = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _products = ExampleProducts.getSampleProducts();
          _isLoadingFirst = false;
        });
      }
      debugPrint("Error loading first page: $e");
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_hasNextPage &&
        !_isLoadingFirst &&
        !_isLoadMoreRunning &&
        _scrollController.position.extentAfter < 200) {
      setState(() => _isLoadMoreRunning = true);
      _page++;

      try {
        final List<Product> newProducts =
            await ProductService.fetchProducts(page: _page);

        if (newProducts.isNotEmpty) {
          setState(() {
            _products.addAll(newProducts);
          });
        } else {
          setState(() => _hasNextPage = false);
        }
      } catch (e) {
        debugPrint("Error loading more: $e");
      } finally {
        if (mounted) {
          setState(() => _isLoadMoreRunning = false);
        }
      }
    }
  }

  void _navigateToDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          initialProduct: product,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final t = AppLocalizations.of(context);
    final width = MediaQuery.maybeOf(context)?.size.width ?? 400;
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F8F8),
      body: _isLoadingFirst
          ? const Center(child: CircularProgressIndicator(color: lazadaOrange))
          : CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. App Bar
                SliverToBoxAdapter(
                  child: LazadaAppBar(
                    searchController: _searchController,
                    readOnly: true,
                    onSearchBarTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchPage()),
                      );
                    },
                  ),
                ),

                // 2. Banner/Carousel Section with Premium Shadow

                SliverToBoxAdapter(
                  child: Container(
                    child: Column(
                      children: [
                        if (_slides.isNotEmpty) // Only show if slides exist
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ClipRRect(
                              // borderRadius: BorderRadius.circular(16),
                              child: ImageCarousel(
                                slides: _slides,
                                height: 180,
                              ),
                            ),
                          ),
                        // const QuickAccessGrid(),
                      ],
                    ),
                  ),
                ),

                // 4. Categories Section
                SliverToBoxAdapter(
                  child: CategorySection(
                    categories: _categories,
                    isLoading: _categories.isEmpty,
                  ),
                ),

                // 3. Flash Sale Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const FlashSaleBanner(),
                  ),
                ),
                // 5. Recommended Section Header
                // SliverToBoxAdapter(
                //   child: SectionHeader(
                //     title: t.translate('just_for_you'),
                //     actionText: t.translate('see_more'),
                //     onActionTap: () {},
                //   ).animate().fadeIn(delay: 400.ms),
                // ),

                // 6. Products Grid
                if (_products.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 10 : 16,
                      vertical: 8,
                    ),
                    sliver: isMobile
                        ? SliverMasonryGrid.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            itemBuilder: (context, index) {
                              return ProductCard(
                                product: _products[index],
                                onTap: () =>
                                    _navigateToDetail(_products[index]),
                              );
                            },
                            childCount: _products.length,
                          )
                        : SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              childAspectRatio: 0.65,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return ProductCard(
                                  product: _products[index],
                                  onTap: () =>
                                      _navigateToDetail(_products[index]),
                                );
                              },
                              childCount: _products.length,
                            ),
                          ),
                  ),

                // 7. Loading More
                if (_isLoadMoreRunning)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 3, color: lazadaOrange)),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ).animate().fadeIn(duration: 600.ms),
    );
  }
}
