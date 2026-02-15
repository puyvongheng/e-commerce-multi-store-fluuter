// lib/services/api_service.dart
import 'package:app1/models/product.dart';
import 'package:app1/models/category.dart';
import 'api_constants.dart';
import 'auth_service.dart';
import 'product_service.dart';
import 'cart_service.dart';
import 'order_service.dart';
import 'package:app1/models/store.dart';
import 'store_service.dart';
import 'address_service.dart';
import 'game_service.dart';

class ApiService {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<Map<String, dynamic>> login(String email, String password) =>
      AuthService.login(email, password);

  static Future<Map<String, dynamic>> getProfile() => AuthService.getProfile();

  static Future<void> logout() => AuthService.logout();

  static Future<List<Product>> fetchProducts({
    int page = 1,
    int? storeId,
    int? categoryId,
    String? sortBy,
  }) =>
      ProductService.fetchProducts(
          page: page, storeId: storeId, categoryId: categoryId, sortBy: sortBy);

  static Future<Map<String, dynamic>> getCategories() =>
      ProductService.getCategories();

  static Future<Product> getProductDetail(int id) =>
      ProductService.getProductDetail(id);

  static Future<void> addToCart(int userId, int productId, int quantity,
          {int? variantId}) =>
      CartService.addToCart(userId, productId, quantity, variantId: variantId);

  static Future<void> deleteFromCart(int userId, int productId,
          {int? variantId}) =>
      CartService.deleteFromCart(userId, productId, variantId: variantId);

  static Future<Map<String, dynamic>> getCart(int userId) =>
      CartService.getCart(userId);

  static Future<void> placeOrder(
          int userId, int addressId, String paymentMethod,
          {List<int>? selectedCartItemIds}) =>
      OrderService.placeOrder(userId, addressId, paymentMethod,
          selectedCartItemIds: selectedCartItemIds);

  static Future<List<dynamic>> getOrders(int userId) =>
      OrderService.getOrders(userId);

  static Future<List<dynamic>> getAddresses(int userId) =>
      AddressService.getAddresses(userId);

  static Future<Map<String, dynamic>> addAddress(Map<String, dynamic> data) =>
      AddressService.addAddress(data);

  static Future<Map<String, dynamic>> updateAddress(
          int id, Map<String, dynamic> data) =>
      AddressService.updateAddress(id, data);

  static Future<void> deleteAddress(int id) => AddressService.deleteAddress(id);

  static Future<Store?> getStoreDetail(int id) =>
      StoreService.fetchStoreDetail(id);

  static Future<List<Product>> fetchFlashSaleProducts({int page = 1}) =>
      ProductService.fetchFlashSaleProducts(page: page);

  static Future<Map<String, dynamic>> claimReward({
    String? gameName,
    int? score,
    int? coins,
  }) =>
      GameService.claimReward(gameName: gameName, score: score, coins: coins);
}
