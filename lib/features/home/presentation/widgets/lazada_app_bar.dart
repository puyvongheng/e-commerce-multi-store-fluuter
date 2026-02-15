// lib/features/home/presentation/widgets/lazada_app_bar.dart

import 'package:flutter/material.dart';
import 'package:app1/features/home/presentation/widgets/search_bar_widget.dart';

class LazadaAppBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onCameraTap;
  final VoidCallback? onSearchBarTap;
  final bool readOnly;

  const LazadaAppBar({
    super.key,
    required this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onCameraTap,
    this.onSearchBarTap,
    this.readOnly = false,
  });

  static const Color lazadaOrange = Color(0xFFFF6600);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              // Use the new Modern SearchBarWidget
              SearchBarWidget(
                controller: searchController,
                hintText: "Search in Store",
                onChanged: onSearchChanged,
                readOnly: readOnly,
                onTap: onSearchBarTap,
                onScanTap: onCameraTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
