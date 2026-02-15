import 'package:flutter/material.dart';
import 'package:app1/services/api_client.dart';
import 'package:app1/models/product.dart';
import 'package:app1/features/product/presentation/widgets/product_card.dart';
import 'package:app1/features/product/presentation/pages/product_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Product> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdStr = prefs.getString('userId') ?? prefs.getString('token');

    if (userIdStr != null) {
      final userId = int.tryParse(userIdStr);
      if (userId != null) {
        try {
          final dio = await ApiClient.getDio();
          final response = await dio.get('/favorite?userId=$userId');

          if (response.data['success'] == true) {
            final List<dynamic> data = response.data['data'];
            if (mounted) {
              setState(() {
                _favorites =
                    data.map((f) => Product.fromJson(f['Product'])).toList();
                _isLoading = false;
              });
            }
          }
        } catch (e) {
          debugPrint("Error loading favorites: $e");
          if (mounted) setState(() => _isLoading = false);
        }
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wishlist",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: _favorites[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(
                                initialProduct: _favorites[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Your wishlist is empty",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
