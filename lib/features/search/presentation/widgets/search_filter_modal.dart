import 'package:flutter/material.dart';
import 'package:app1/models/category.dart';

class SearchFilterModal extends StatefulWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final RangeValues priceRange;
  final String selectedSort;
  final Function(int?, RangeValues, String) onApply;

  const SearchFilterModal({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.priceRange,
    required this.selectedSort,
    required this.onApply,
  });

  @override
  State<SearchFilterModal> createState() => _SearchFilterModalState();
}

class _SearchFilterModalState extends State<SearchFilterModal> {
  late int? _tempCategory;
  late RangeValues _tempPriceRange;
  late String _tempSort;

  @override
  void initState() {
    super.initState();
    _tempCategory = widget.selectedCategoryId;
    _tempPriceRange = widget.priceRange;
    _tempSort = widget.selectedSort;
  }

  TextStyle _labelStyle(bool isDark) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey[300] : Colors.grey[700],
      );

  Widget _buildSortChip(String label, String value) {
    final isSelected = _tempSort == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.orange.withOpacity(0.2),
      labelStyle: TextStyle(
          color: isSelected ? Colors.orange : null,
          fontWeight: isSelected ? FontWeight.bold : null),
      onSelected: (selected) {
        if (selected) setState(() => _tempSort = value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Filter & Sort',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Sort Options
          Text('Sort By', style: _labelStyle(isDark)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              _buildSortChip('Newest', 'new'),
              _buildSortChip('Price Low-High', 'price_asc'),
              _buildSortChip('Price High-Low', 'price_desc'),
            ],
          ),
          const SizedBox(height: 20),

          // Categories
          Text('Category', style: _labelStyle(isDark)),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: _tempCategory,
            dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: [
              const DropdownMenuItem<int>(
                  value: null, child: Text('All Categories')),
              ...widget.categories.map(
                  (c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
            ],
            onChanged: (val) => setState(() => _tempCategory = val),
          ),
          const SizedBox(height: 20),

          // Price Range
          Text(
              'Price Range (\$${_tempPriceRange.start.toInt()} - \$${_tempPriceRange.end.toInt()})',
              style: _labelStyle(isDark)),
          RangeSlider(
            values: _tempPriceRange,
            min: 0,
            max: 5000,
            divisions: 50,
            activeColor: Colors.orange,
            labels: RangeLabels(
              '\$${_tempPriceRange.start.toInt()}',
              '\$${_tempPriceRange.end.toInt()}',
            ),
            onChanged: (values) => setState(() => _tempPriceRange = values),
          ),

          const Spacer(),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Reset Logic
                    setState(() {
                      _tempCategory = null;
                      _tempPriceRange = const RangeValues(0, 5000);
                      _tempSort = 'new';
                    });
                    widget.onApply(null, const RangeValues(0, 5000), 'new');
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    widget.onApply(_tempCategory, _tempPriceRange, _tempSort);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
