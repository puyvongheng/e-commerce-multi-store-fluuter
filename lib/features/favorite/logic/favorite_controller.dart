import 'package:app1/features/favorite/data/favorite_repository.dart';
import 'package:app1/models/product.dart';
import 'package:get/get.dart';

class FavoriteController extends GetxController {
  final FavoriteRepository _repository = FavoriteRepository();

  var favorites = <Product>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    isLoading.value = true;
    try {
      final fetchedFavorites = await _repository.getFavorites();
      favorites.assignAll(fetchedFavorites);
    } catch (e) {
      print("Error loading favorites: $e");
      // Optionally show error snackbar
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(Product product) async {
    final index = favorites.indexWhere((p) => p.id == product.id);
    final isFavorite = index != -1;

    // Optimistic update
    if (isFavorite) {
      favorites.removeAt(index);
    } else {
      favorites.add(product);
    }

    final success = await _repository.toggleFavorite(product.id);

    if (!success) {
      // Revert if failed
      if (isFavorite) {
        favorites.insert(index, product);
      } else {
        favorites.remove(product);
      }
      Get.snackbar('Error', 'Failed to update favorites');
    } else {
      Get.snackbar(
        isFavorite ? 'Removed' : 'Added',
        isFavorite ? 'Removed from favorites' : 'Added to favorites',
        duration: const Duration(seconds: 1),
      );
    }
  }

  // Method to refresh the list, useful when returning to the page
  Future<void> refreshFavorites() async {
    await loadFavorites();
  }
}
