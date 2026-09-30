import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../repositories/cart_repository.dart';

class CartViewModel extends ChangeNotifier {
  final CartRepository _repository;

  CartViewModel({required CartRepository repository})
      : _repository = repository;

  List<CartItem> get items => _repository.items;

  int get itemCount => _repository.itemCount;

  int get totalQuantity => _repository.totalQuantity;

  double get subtotal => _repository.subtotal;

  double get totalWithDelivery => _repository.subtotal + AppConstants.deliveryCharge;

  double get savings => _repository.savings;

  bool get isEmpty => _repository.isEmpty;

  bool get isNotEmpty => !_repository.isEmpty;

  bool contains(int productId) => _repository.contains(productId);

  CartItem? getItem(int productId) => _repository.getItem(productId);

  int quantityOf(int productId) {
    return _repository.getItem(productId)?.quantity ?? 0;
  }

  void addToCart(Product product, {int quantity = 1}) {
    _repository.addProduct(product, quantity: quantity);
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _repository.removeProduct(productId);
    notifyListeners();
  }

  void increment(int productId) {
    _repository.incrementQuantity(productId);
    notifyListeners();
  }

  void decrement(int productId) {
    _repository.decrementQuantity(productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    _repository.updateQuantity(productId, quantity);
    notifyListeners();
  }

  void clearCart() {
    _repository.clear();
    notifyListeners();
  }
}