import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../repositories/cart_repository.dart';
import '../services/auth_service.dart';

class CartViewModel extends ChangeNotifier {
  final CartRepository _repository;
  final AuthService _authService;

  CartViewModel({
    required CartRepository repository,
    required AuthService authService,
  })  : _repository = repository,
        _authService = authService;

  List<CartItem> get items => _repository.items;
  int get itemCount => _repository.itemCount;
  int get totalQuantity => _repository.totalQuantity;
  double get subtotal => _repository.subtotal;
  double get savings => _repository.savings;
  bool get isEmpty => _repository.isEmpty;
  bool get isNotEmpty => !_repository.isEmpty;

  bool contains(int productId) => _repository.contains(productId);
  CartItem? getItem(int productId) => _repository.getItem(productId);

  int quantityOf(int productId) {
    return _repository.getItem(productId)?.quantity ?? 0;
  }

  Future<void> loadCart() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    await _repository.loadCart(userId);
    notifyListeners();
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    await _repository.addProduct(product, userId, quantity: quantity);
    notifyListeners();
  }

  Future<void> removeFromCart(int productId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    await _repository.removeProduct(productId, userId);
    notifyListeners();
  }

  Future<void> increment(int productId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    await _repository.incrementQuantity(productId, userId);
    notifyListeners();
  }

  Future<void> decrement(int productId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    await _repository.decrementQuantity(productId, userId);
    notifyListeners();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    await _repository.updateQuantity(productId, quantity, userId);
    notifyListeners();
  }

  Future<void> clearCart() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    await _repository.clear(userId);
    notifyListeners();
  }

  void clearLocalState() {
    _repository.clearLocalState();
    notifyListeners();
  }
}