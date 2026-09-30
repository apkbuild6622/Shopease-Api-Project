import 'package:flutter/foundation.dart';
import '../core/errors/app_exception.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

enum ProductViewState { idle, loading, success, error }

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  ProductViewModel({required ProductRepository repository})
      : _repository = repository;

  ProductViewState _state = ProductViewState.idle;
  ProductViewState get state => _state;

  List<Product> _products = [];
  List<Product> get products => List.unmodifiable(_products);

  List<String> _categories = [];
  List<String> get categories => List.unmodifiable(_categories);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int _skip = 0;
  final int _limit = 30;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  int _totalProducts = 0;
  int get totalProducts => _totalProducts;

  bool get isLoading => _state == ProductViewState.loading;
  bool get hasError => _state == ProductViewState.error;
  bool get hasData => _products.isNotEmpty;
  bool get isEmpty => _state == ProductViewState.success && _products.isEmpty;

  List<Product> get promotionalProducts {
    return _products.where((p) => p.isDiscounted).take(5).toList();
  }

  Future<void> fetchProducts() async {
    _state = ProductViewState.loading;
    _skip = 0;
    _hasMore = true;    // ← enable
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getAllProducts(
        limit: _limit,
        skip: _skip,
      );
      _products = result;
      _totalProducts = result.length;
      _skip = result.length;
      _hasMore = result.length == _limit;    // ← agar 30 aaye to aur hain
      _state = ProductViewState.success;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _state = ProductViewState.error;
    } catch (_) {
      _errorMessage = 'Unexpected error occurred.';
      _state = ProductViewState.error;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _state == ProductViewState.loading) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.getAllProducts(
        limit: _limit,
        skip: _skip,
      );
      if (result.isEmpty) {
        _hasMore = false;
      } else {
        _products = [..._products, ...result];   // ← append
        _skip += result.length;
        _hasMore = result.length == _limit;
      }
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Unexpected error occurred.';
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> selectCategory(String category) async {
    _selectedCategory = category;
    _searchQuery = '';
    await _applyFilter();
  }

  Future<void> search(String query) async {
    _searchQuery = query.trim();
    if (_searchQuery.isEmpty) {
      if (_selectedCategory == 'All') {
        await fetchProducts();
      } else {
        await _applyFilter();
      }
      return;
    }
    await _applyFilter();
  }

  Future<void> clearSearch() async {
    _searchQuery = '';
    _selectedCategory = 'All';
    await fetchProducts();
  }

  Future<void> refresh() async {
    if (_searchQuery.isNotEmpty || _selectedCategory != 'All') {
      await _applyFilter();
    } else {
      await fetchProducts();
    }
  }

  Future<void> _applyFilter() async {
    _state = ProductViewState.loading;
    _errorMessage = null;
    _hasMore = false;
    notifyListeners();

    try {
      List<Product> result;

      if (_searchQuery.isNotEmpty) {
        result = await _repository.searchProducts(_searchQuery);
      } else if (_selectedCategory != 'All') {
        result = await _repository.getProductsByCategory(_selectedCategory);
      } else {
        result = await _repository.getAllProducts(
          limit: _limit,
          skip: 0,
        );
      }

      _products = result;
      _totalProducts = result.length;
      _state = ProductViewState.success;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _state = ProductViewState.error;
    } catch (_) {
      _errorMessage = 'Unexpected error occurred.';
      _state = ProductViewState.error;
    }
    notifyListeners();
  }

  void clearError() {
    if (_state == ProductViewState.error) {
      _errorMessage = null;
      _state = ProductViewState.idle;
      notifyListeners();
    }
  }
}