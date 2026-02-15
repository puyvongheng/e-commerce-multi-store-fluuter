import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/models/store.dart';
import 'package:app1/features/store/presentation/pages/store_profile_page.dart';

class SelectedStoreCardWidget extends StatelessWidget {
  final Store store;
  final String imageUrl;
  final double? distance;

  const SelectedStoreCardWidget({
    super.key,
    required this.store,
    required this.imageUrl,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double cardMaxWidth = 500.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: cardMaxWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildStoreImage(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (store.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded,
                              color: Colors.blue, size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            store.businessType ?? 'Shop',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (distance != null) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.circle, size: 3, color: Colors.grey[400]),
                          const SizedBox(width: 6),
                          Text(
                            "${(distance! / 1000).toStringAsFixed(1)} km",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 12, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            store.address ?? 'No address',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
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
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: Colors.black12,
                radius: 18,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.black),
                  onPressed: () => Get.to(() => StoreProfilePage(store: store)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreImage() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.store_mall_directory_outlined,
                    color: Colors.grey),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)));
                },
              )
            : const Icon(Icons.store_mall_directory_outlined,
                size: 30, color: Colors.grey),
      ),
    );
  }
}
