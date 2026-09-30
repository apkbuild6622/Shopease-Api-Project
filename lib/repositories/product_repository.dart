import '../models/product.dart';
import '../services/api_service.dart';

class ProductRepository {
  final ApiService _apiService;

  ProductRepository({required ApiService apiService})
      : _apiService = apiService;

  Future<List<Product>> getAllProducts({int limit = 30, int skip = 0}) async {
    final data = await _apiService.get(
      '/products?limit=$limit&skip=$skip',
    );
    return _parseProductList(data);
  }

  Future<Product> getProductById(int id) async {
    final data = await _apiService.get('/products/$id');
    return Product.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Product>> searchProducts(String query) async {
    final data = await _apiService.get(
      '/products/search?q=${Uri.encodeComponent(query)}',
    );
    return _parseProductList(data);
  }

  Future<List<String>> getCategories() async {
    final data = await _apiService.get('/products/category-list');
    return (data as List<dynamic>).map((e) => e as String).toList();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final data = await _apiService.get(
      '/products/category/${Uri.encodeComponent(category)}',
    );
    return _parseProductList(data);
  }

  List<Product> _parseProductList(dynamic data) {
    final map = data as Map<String, dynamic>;
    final list = map['products'] as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}