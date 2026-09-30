import '../models/cart_item.dart';
import '../models/product.dart';

class CartRepository {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get itemCount => _items.length;

  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  double get savings =>
      _items.values.fold(0.0, (sum, item) => sum + item.savings);

  bool get isEmpty => _items.isEmpty;

  bool contains(int productId) => _items.containsKey(productId);

  CartItem? getItem(int productId) => _items[productId];

  void addProduct(Product product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItem(
        product: product,
        quantity: quantity,
      );
    }
  }

  void removeProduct(int productId) {
    _items.remove(productId);
  }

  void incrementQuantity(int productId) {
    final item = _items[productId];
    if (item != null) {
      item.increment();
    }
  }

  void decrementQuantity(int productId) {
    final item = _items[productId];
    if (item != null) {
      if (item.quantity > 1) {
        item.decrement();
      }
    }
  }

  void updateQuantity(int productId, int quantity) {
    final item = _items[productId];
    if (item != null && quantity > 0) {
      item.quantity = quantity;
    }
  }

  void clear() {
    _items.clear();
  }
}