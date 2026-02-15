import 'package:flutter/material.dart';
import 'package:app1/models/category.dart';
import 'package:app1/models/product.dart';
import 'package:app1/services/product_service.dart';
import 'package:app1/features/product/presentation/widgets/product_card.dart';
import 'package:app1/features/product/presentation/pages/product_detail_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Components
import '../widgets/category_sliver_app_bar.dart';
import '../widgets/category_sort_filter.dart';
import '../widgets/category_empty_state.dart';

class CategoryPage extends StatefulWidget {
  final Category category;

  const CategoryPage({super.key, required this.category});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Product> _products = [];
  List<Category> _subCategories = [];
  List<Map<String, dynamic>> _breadcrumbs = [];
  bool _isLoading = true;
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch Products
      final products = await ProductService.fetchProducts(
        categoryId: widget.category.id,
        sortBy: _sortBy,
      );

      // 2. Fetch Sub-categories and Breadcrumbs
      final categoryResult =
          await ProductService.getCategories(categoryId: widget.category.id);

      if (mounted) {
        setState(() {
          _products = products;
          _subCategories = categoryResult['categories'] as List<Category>;
          _breadcrumbs =
              categoryResult['breadcrumbs'] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSortChanged(String sort) {
    if (_sortBy != sort) {
      setState(() => _sortBy = sort);
      _fetchData();
    }
  }

  void _navigateToCategory(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPage(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CategorySliverAppBar(category: widget.category),

          // 1. Breadcrumbs
          if (_breadcrumbs.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildBreadcrumbs(isDark),
            ),

          // 2. Sub-categories
          if (_subCategories.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildSubCategories(isDark),
            ),

          SliverToBoxAdapter(
            child: CategorySortFilter(
              currentSort: _sortBy,
              onSortChanged: _onSortChanged,
            ),
          ),
          _isLoading
              ? _buildLoadingGrid(isDark)
              : _products.isEmpty
                  ? const CategoryEmptyState()
                  : _buildProductGrid(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs(bool isDark) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _breadcrumbs.length + 1, // +1 for "Home"
        separatorBuilder: (_, __) => Icon(
          Icons.chevron_right_rounded,
          size: 14,
          color: isDark ? Colors.white30 : Colors.grey[400],
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: Center(
                child: Text(
                  "Home",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          }
          final crumb = _breadcrumbs[index - 1];
          final isLast = index == _breadcrumbs.length;
          return GestureDetector(
            onTap: isLast
                ? null
                : () {
                    // Navigate to parent
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryPage(
                          category:
                              Category(id: crumb['id'], name: crumb['name']),
                        ),
                      ),
                    );
                  },
            child: Center(
              child: Text(
                crumb['name'] + (isLast ? " ក្នុង កម្ពុជា" : ""),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isLast
                      ? const Color(0xFFFF6600)
                      : (isDark ? Colors.white70 : Colors.grey[500]),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubCategories(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            "Subcategories",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _subCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final cat = _subCategories[index];
              return GestureDetector(
                onTap: () => _navigateToCategory(cat),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: cat.image != null
                          ? Image.network(cat.image!, fit: BoxFit.cover)
                          : const Icon(Icons.category_outlined, size: 25),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 70,
                      child: Text(
                        cat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid() {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = width > 1200 ? 6 : (width > 800 ? 4 : 2);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: width < 600
              ? 0.58
              : 0.7, // Fine-tuned for mobile to prevent overflow
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = _products[index];
            return ProductCard(
              product: product,
              onTap: () => _navigateToDetail(product),
              onAddTap: () => _navigateToDetail(product),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                .slideY(begin: 0.1, end: 0);
          },
          childCount: _products.length,
        ),
      ),
    );
  }

  Widget _buildLoadingGrid(bool isDark) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = width > 1200 ? 6 : (width > 800 ? 4 : 2);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: width < 600 ? 0.58 : 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms);
          },
          childCount: 6,
        ),
      ),
    );
  }

  void _navigateToDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(initialProduct: product),
      ),
    );
  }
}
