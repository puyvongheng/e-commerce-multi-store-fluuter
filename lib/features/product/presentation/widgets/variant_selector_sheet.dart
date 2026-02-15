import 'package:flutter/material.dart';
import 'package:app1/models/product.dart';
import 'package:app1/models/product_variant.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'variant_selector_header.dart';
import 'variant_selector_attribute.dart';
import 'variant_selector_quantity.dart';

class VariantSelectorSheet extends StatefulWidget {
  final Product product;
  final ProductVariant? initialVariant;
  final int initialQuantity;
  final Function(ProductVariant?, int) onConfirm;

  const VariantSelectorSheet({
    super.key,
    required this.product,
    this.initialVariant,
    this.initialQuantity = 1,
    required this.onConfirm,
  });

  @override
  State<VariantSelectorSheet> createState() => _VariantSelectorSheetState();
}

class _VariantSelectorSheetState extends State<VariantSelectorSheet> {
  late ProductVariant? _selectedVariant;
  late int _quantity;

  // Selection state for multiple attributes
  final Map<String, String> _selectedAttributes = {};

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.initialVariant ??
        (widget.product.variants.isNotEmpty
            ? widget.product.variants.first
            : null);
    _quantity = widget.initialQuantity;

    // Initialize selected attributes from the selected variant
    if (_selectedVariant != null) {
      for (var opt in _selectedVariant!.attributeOptions) {
        if (opt.attributeName != null) {
          _selectedAttributes[opt.attributeName!] = opt.value;
        }
      }
    }
  }

  void _onAttributeSelected(String attrName, String value) {
    setState(() {
      _selectedAttributes[attrName] = value;

      // Find a variant that matches all selected attributes
      final match = widget.product.variants.firstWhere(
        (v) {
          bool allMatch = true;
          for (var entry in _selectedAttributes.entries) {
            bool hasAttr = v.attributeOptions.any((opt) =>
                opt.attributeName == entry.key && opt.value == entry.value);
            if (!hasAttr) {
              allMatch = false;
              break;
            }
          }
          return allMatch;
        },
        orElse: () => widget.product.variants.first,
      );
      _selectedVariant = match;

      // Clamp quantity to new max stock
      final maxStock = _selectedVariant?.qty ?? widget.product.qty;
      if (maxStock != null && _quantity > maxStock) {
        _quantity = maxStock > 0 ? maxStock : 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color lazadaOrange = Color(0xFFFF6600);
    final currentPrice = _selectedVariant?.price ?? widget.product.price;
    final displayImage = _selectedVariant?.image ?? widget.product.image;

    // Grouping logic: Get all unique attributes and their options from all variants
    Map<String, Set<String>> allAttributes = {};
    for (var v in widget.product.variants) {
      for (var opt in v.attributeOptions) {
        if (opt.attributeName != null) {
          allAttributes
              .putIfAbsent(opt.attributeName!, () => {})
              .add(opt.value);
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          VariantSelectorHeader(
            imageUrl: displayImage,
            price: currentPrice,
            stock_main: widget.product.qty,
            stock: _selectedVariant?.qty,
            attributesSummary: _selectedVariant?.attributesSummary ?? "",
            isDark: isDark,
            onClose: () => Navigator.pop(context),
          ),

          // Scrollable
          //
          // Content
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dynamic Attribute Sections
                  if (allAttributes.isNotEmpty)
                    ...allAttributes.entries.map((entry) {
                      final attrName = entry.key;
                      final options = entry.value;
                      return VariantSelectorAttribute(
                        name: attrName,
                        options: options,
                        selectedValue: _selectedAttributes[attrName],
                        isDark: isDark,
                        onSelected: (value) =>
                            _onAttributeSelected(attrName, value),
                      );
                    }),

                  // Fallback to simple variant list if no attributes are named
                  if (allAttributes.isEmpty &&
                      widget.product.variants.isNotEmpty)
                    _buildLegacyVariantList(isDark, lazadaOrange),

                  const SizedBox(height: 20),

                  // Quantity UI
                  VariantSelectorQuantity(
                    quantity: _quantity,
                    maxQuantity: _selectedVariant?.qty ?? widget.product.qty,
                    isDark: isDark,
                    onIncrement: () {
                      final maxStock =
                          _selectedVariant?.qty ?? widget.product.qty;
                      if (maxStock == null || _quantity < maxStock) {
                        setState(() => _quantity++);
                      }
                    },
                    onDecrement: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  widget.onConfirm(_selectedVariant, _quantity);
                  Navigator.pop(context); // Close sheet after confirm
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: lazadaOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                  elevation: 0,
                ),
                child: const Text(
                  "Confirm Selection",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(
              height: MediaQuery.of(context).viewPadding.bottom > 0 ? 10 : 20),
        ],
      ),
    );
  }

  Widget _buildLegacyVariantList(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            "Variation",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.product.variants.map((v) {
            final isSelected = _selectedVariant?.id == v.id;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedVariant = v;
                  // Clamp quantity
                  final maxStock = _selectedVariant?.qty ?? widget.product.qty;
                  if (maxStock != null && _quantity > maxStock) {
                    _quantity = maxStock > 0 ? maxStock : 1;
                  }
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: 200.ms,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withOpacity(0.1)
                      : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.transparent,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  v.sku ?? 'Option ${v.id}',
                  style: TextStyle(
                    color: isSelected
                        ? primaryColor
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
