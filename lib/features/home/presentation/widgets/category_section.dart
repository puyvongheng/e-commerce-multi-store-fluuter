import 'package:flutter/material.dart';
import 'package:app1/models/category.dart';
import 'package:app1/features/category/presentation/pages/category_page.dart';
import 'package:app1/features/category/presentation/pages/all_categories_page.dart';
import 'package:app1/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CategorySection extends StatelessWidget {
  final List<Category> categories;
  final bool isLoading;

  const CategorySection({
    super.key,
    required this.categories,
    this.isLoading = false,
  });

  static const Color lazadaOrange = Color(0xFFFF6600);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Row(
        //         children: [
        //           Container(
        //             padding: const EdgeInsets.all(8),
        //             decoration: BoxDecoration(
        //               color: lazadaOrange.withOpacity(0.1),
        //               borderRadius: BorderRadius.circular(10),
        //             ),
        //             child: const Icon(Icons.category_rounded,
        //                 color: lazadaOrange, size: 20),
        //           ),
        //           const SizedBox(width: 8),
        //           Text(
        //             t.translate('categories'),
        //             style: TextStyle(
        //               fontSize: 18,
        //               fontWeight: FontWeight.bold,
        //               color: isDark ? Colors.white : Colors.black87,
        //               letterSpacing: 0.5,
        //             ),
        //           ),
        //         ],
        //       ),
        //       InkWell(
        //         onTap: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (_) => const AllCategoriesPage(),
        //             ),
        //           );
        //         },
        //         borderRadius: BorderRadius.circular(20),
        //         child: Padding(
        //           padding:
        //               const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        //           child: Row(
        //             children: [
        //               Text(
        //                 t.translate('view_all'),
        //                 style: TextStyle(
        //                   color: lazadaOrange,
        //                   fontWeight: FontWeight.w600,
        //                   fontSize: 14,
        //                 ),
        //               ),
        //               const SizedBox(width: 4),
        //               const Icon(Icons.arrow_forward_ios_rounded,
        //                   color: lazadaOrange, size: 12),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ],

        //   ),
        // ),

        // Horizontal List
        SizedBox(
          height: 140, // Height for the single row of cards
          child: isLoading
              ? _buildLoadingList(isDark)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return _CategoryCard(
                      category: categories[index],
                      index: index,
                      isDark: isDark,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLoadingList(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) => _LoadingCard(isDark: isDark),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final int index;
  final bool isDark;

  const _CategoryCard({
    required this.category,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryPage(category: category),
          ),
        );
      },
      child: Container(
        width: 110, // Fixed width for "big" friendly look
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Image Background
              category.image != null && category.image!.isNotEmpty
                  ? Image.network(
                      category.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDark ? Colors.white30 : Colors.black12,
                            ),
                          ),
                        );
                      },
                    )
                  : _buildPlaceholder(),

              // 2. Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),

              // 3. Text
              Positioned(
                bottom: 10,
                left: 8,
                right: 8,
                child: Text(
                  category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 50).ms)
        .slideX(begin: 0.1, end: 0)
        .scale(
          begin: const Offset(0.95, 0.95),
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: isDark ? Colors.white24 : Colors.grey[400],
          size: 30,
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final bool isDark;
  const _LoadingCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer();
  }
}
