import 'package:flutter/material.dart';
import 'package:app1/models/product.dart';
import 'package:app1/models/category.dart';
import 'package:app1/services/product_service.dart';
import 'package:app1/features/product/presentation/widgets/product_card.dart';
import 'package:app1/features/product/presentation/pages/product_detail_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/l10n/app_localizations.dart';

import 'package:app1/features/store/presentation/pages/map_store_page.dart';

class FilterSearchPage extends StatefulWidget {
  final String? initialQuery;
  const FilterSearchPage({super.key, this.initialQuery});

  @override
  State<FilterSearchPage> createState() => _FilterSearchPageState();
}

class _FilterSearchPageState extends State<FilterSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Category> _categories = [];
  bool _isLoading = true;

  int? _selectedCategoryId;
  double _minPrice = 0;
  double _maxPrice = 5000;
  String _sortBy = 'newest'; // 'newest', 'price_low', 'price_high'

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? "";
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final products = await ProductService.fetchProducts(page: 1);
      final result = await ProductService.getCategories();
      if (mounted) {
        setState(() {
          _allProducts = products;
          _categories = result['categories'] as List<Category>;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      debugPrint("Error fetching filter data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final queryMatch = product.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        final priceMatch =
            product.price >= _minPrice && product.price <= _maxPrice;
        return queryMatch && priceMatch;
      }).toList();

      if (_sortBy == 'price_low') {
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
      } else if (_sortBy == 'price_high') {
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
      }
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Filter Options",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              const Text("Category",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length + 1,
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final catId = isAll ? null : _categories[index - 1].id;
                    final catName = isAll ? "All" : _categories[index - 1].name;
                    final isSelected = _selectedCategoryId == catId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(catName),
                        selected: isSelected,
                        onSelected: (val) {
                          setModalState(() => _selectedCategoryId = catId);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text("Price Range",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              RangeSlider(
                values: RangeValues(_minPrice, _maxPrice),
                min: 0,
                max: 5000,
                divisions: 50,
                labels: RangeLabels(
                    "\$${_minPrice.round()}", "\$${_maxPrice.round()}"),
                onChanged: (values) {
                  setModalState(() {
                    _minPrice = values.start;
                    _maxPrice = values.end;
                  });
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFFF6600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: const Text("Apply Filters",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            onSubmitted: (val) => _applyFilters(),
            decoration: const InputDecoration(
              hintText: "Search products...",
              prefixIcon: Icon(Icons.search, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 8),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MapStorePage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredProducts.isEmpty
              ? Center(child: Text(t.translate('no_results')))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${_filteredProducts.length} items found",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.grey)),
                          DropdownButton<String>(
                            value: _sortBy,
                            underline: const SizedBox(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _sortBy = val);
                                _applyFilters();
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                  value: 'newest', child: Text("Newest")),
                              DropdownMenuItem(
                                  value: 'price_low',
                                  child: Text("Price: Low to High")),
                              DropdownMenuItem(
                                  value: 'price_high',
                                  child: Text("Price: High to Low")),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: _filteredProducts[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailPage(
                                    initialProduct: _filteredProducts[index]),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: (index * 50).ms)
                              .slideY(begin: 0.1, end: 0);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
