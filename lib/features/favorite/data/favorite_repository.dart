import 'package:app1/models/product.dart';
import 'package:app1/services/favorite_service.dart';

class FavoriteRepository {
  Future<List<Product>> getFavorites() async {
    return await FavoriteService.getFavorites();
  }

  Future<bool> toggleFavorite(int productId) async {
    try {
      final result = await FavoriteService.toggleFavorite(productId);
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
