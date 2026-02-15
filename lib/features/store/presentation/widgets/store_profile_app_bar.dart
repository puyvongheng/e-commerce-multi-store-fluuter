import 'package:flutter/material.dart';
import 'package:app1/models/store.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StoreProfileSliverAppBar extends StatelessWidget {
  final Store store;
  final bool isDark;
  final VoidCallback onBack;
  final VoidCallback onSearch;
  final VoidCallback onMore;

  const StoreProfileSliverAppBar({
    super.key,
    required this.store,
    required this.isDark,
    required this.onBack,
    required this.onSearch,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    const Color storeColor = Color(0xFF0F172A);

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      leading: IconButton(
        icon: const ContainerWithBlur(
            child: Icon(Icons.arrow_back_rounded, color: Colors.white)),
        onPressed: onBack,
      ),
      // actions: [
      //   IconButton(
      //     icon: const ContainerWithBlur(
      //         child: Icon(Icons.search_rounded, color: Colors.white)),
      //     onPressed: onSearch,
      //   ),
      //   IconButton(
      //     icon: const ContainerWithBlur(
      //         child: Icon(Icons.more_vert_rounded, color: Colors.white)),
      //     onPressed: onMore,
      //   ),
      //   const SizedBox(width: 8),
      // ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover Image
            if (store.coverImage != null && store.coverImage!.isNotEmpty)
              Image.network(
                store.coverImage!,
                fit: BoxFit.cover,
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.blue.shade900,
                      const Color(0xFF0F172A),
                    ],
                  ),
                ),
                child: Opacity(
                  opacity: 0.1,
                  child: Image.network(
                    "https://www.transparenttextures.com/patterns/cubes.png",
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),

            // Gradient Overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.6, 1.0],
                ),
              ),
            ),

            // Store Info Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    // Store Logo
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            store.logo != null && store.logo!.isNotEmpty
                                ? NetworkImage(store.logo!)
                                : null,
                        child: store.logo == null || store.logo!.isEmpty
                            ? const Icon(Icons.store_rounded,
                                size: 36, color: storeColor)
                            : null,
                      ),
                    )
                        .animate()
                        .scale(curve: Curves.easeOutBack, duration: 600.ms),

                    const SizedBox(width: 16),

                    // Store Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  store.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black45,
                                          blurRadius: 4,
                                          offset: Offset(0, 2))
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (store.isVerified)
                                const Icon(Icons.verified_rounded,
                                    color: Colors.blueAccent, size: 20),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (store.description != null &&
                              store.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                store.description!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (store.address != null &&
                              store.address!.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    store.address!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class ContainerWithBlur extends StatelessWidget {
  final Widget child;
  const ContainerWithBlur({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
