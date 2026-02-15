import 'package:flutter/material.dart';
import 'package:app1/models/category.dart';

class CategorySliverAppBar extends StatelessWidget {
  final Category category;

  const CategorySliverAppBar({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        title: Text(
          category.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image/Gradient
            if (category.image != null && category.image!.isNotEmpty)
              Image.network(
                category.image!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderBackground(),
              )
            else
              _buildPlaceholderBackground(),

            // Premium Overlay Gradient
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black26,
                    Colors.transparent,
                    Colors.black87,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!,
            const Color(0xFF1A1A1A),
          ],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.1,
          child: Icon(Icons.category_rounded, size: 120, color: Colors.white),
        ),
      ),
    );
  }
}
