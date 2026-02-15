import 'package:flutter/material.dart';

class ProfileStatsBar extends StatelessWidget {
  final int wishlistCount;
  final int cartCount;
  final int couponCount;

  const ProfileStatsBar({
    super.key,
    required this.wishlistCount,
    required this.cartCount,
    required this.couponCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem("Wishlist", wishlistCount, Icons.favorite_border),
        _buildContainerLine(),
        _buildStatItem("In Cart", cartCount, Icons.shopping_cart_outlined),
        _buildContainerLine(),
        _buildStatItem("Coupons", couponCount, Icons.local_offer_outlined),
      ],
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Badge(
          label: Text(count.toString()),
          backgroundColor: Colors.redAccent,
          isLabelVisible: count > 0,
          child: Icon(icon, size: 28, color: Colors.grey[700]),
        ),
        const SizedBox(height: 5),
        Text(label,
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildContainerLine() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[300],
    );
  }
}
