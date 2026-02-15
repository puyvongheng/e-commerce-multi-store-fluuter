import 'package:flutter/material.dart';

class CategorySortFilter extends StatelessWidget {
  final String currentSort;
  final Function(String) onSortChanged;

  const CategorySortFilter({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _SortChip(
                  label: "Newest",
                  icon: Icons.auto_awesome_rounded,
                  value: "newest",
                  isSelected: currentSort == "newest",
                  onTap: () => onSortChanged("newest"),
                ),
                _SortChip(
                  label: "Price Low",
                  icon: Icons.trending_up_rounded,
                  value: "price_asc",
                  isSelected: currentSort == "price_asc",
                  onTap: () => onSortChanged("price_asc"),
                ),
                _SortChip(
                  label: "Price High",
                  icon: Icons.trending_down_rounded,
                  value: "price_desc",
                  isSelected: currentSort == "price_desc",
                  onTap: () => onSortChanged("price_desc"),
                ),
                _SortChip(
                  label: "A-Z",
                  icon: Icons.sort_by_alpha_rounded,
                  value: "name_asc",
                  isSelected: currentSort == "name_asc",
                  onTap: () => onSortChanged("name_asc"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
