import 'package:app1/models/category.dart';
import 'package:app1/models/product.dart';
import 'package:app1/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/features/home/presentation/widgets/search_bar_widget.dart';
import 'dart:async';

import '../widgets/search_filter_modal.dart';
import '../widgets/search_recent_list.dart';
import '../widgets/search_results_grid.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  // Search State
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  List<Category> _categories = [];
  int? _selectedCategoryId;
  RangeValues _priceRange = const RangeValues(0, 5000);
  String _selectedSort = 'new';

  final List<String> _recentSearches = [
    'iPhone',
    'Samsung',
    'Headphones',
    'Shoes',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    _fetchCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    final result = await ProductService.getCategories();
    if (mounted) {
      setState(() => _categories = result['categories'] as List<Category>);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (query.isNotEmpty) {
        _performSearch();
      } else {
        setState(() => _products = []);
      }
    });
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await ProductService.searchProducts(
        query: _searchController.text,
        categoryId: _selectedCategoryId,
        minPrice: _priceRange.start > 0 ? _priceRange.start : null,
        maxPrice: _priceRange.end < 5000 ? _priceRange.end : null,
        sort: _selectedSort,
      );
      if (mounted) setState(() => _products = results);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFilterModal(
        categories: _categories,
        selectedCategoryId: _selectedCategoryId,
        priceRange: _priceRange,
        selectedSort: _selectedSort,
        onApply: (catId, range, sort) {
          setState(() {
            _selectedCategoryId = catId;
            _priceRange = range;
            _selectedSort = sort;
          });
          _performSearch();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : Colors.black87),
                  ),
                  Expanded(
                    child: Hero(
                      tag: 'searchBar',
                      child: Material(
                        type: MaterialType.transparency,
                        child: SearchBarWidget(
                          controller: _searchController,
                          hintText: "Search products...",
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _openFilterModal,
                    icon: Stack(
                      children: [
                        const Icon(Icons.tune_rounded),
                        if (_selectedCategoryId != null ||
                            _priceRange.start > 0 ||
                            _selectedSort != 'new')
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    tooltip: 'Filter',
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.orange))
                  : _searchController.text.isEmpty
                      ? SearchRecentList(
                          recentSearches: _recentSearches,
                          isDark: isDark,
                          onSearchTap: (val) {
                            _searchController.text = val;
                            _performSearch();
                          },
                        )
                      : _products.isEmpty
                          ? _buildEmptyState(isDark)
                          : SearchResultsGrid(
                              products: _products,
                              error: _error,
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No results found",
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
