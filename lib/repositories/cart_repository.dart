import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  CollectionReference<Map<String, dynamic>> _cartRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart');
  }

  Future<void> loadCart(String userId) async {
    try {
      final snapshot = await _cartRef(userId).get();
      _items.clear();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final productData = data['product'] as Map<String, dynamic>;
        final product = Product.fromJson(productData);
        _items[product.id] = CartItem(
          product: product,
          quantity: data['quantity'] as int? ?? 1,
        );
      }
    } catch (e) {
      _items.clear();
    }
  }

  Future<void> _saveItem(String userId, CartItem item) async {
    await _cartRef(userId).doc(item.product.id.toString()).set({
      'quantity': item.quantity,
      'product': _productToMap(item.product),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addProduct(
      Product product,
      String userId, {
        int quantity = 1,
      }) async {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
    await _saveItem(userId, _items[product.id]!);
  }

  Future<void> removeProduct(int productId, String userId) async {
    _items.remove(productId);
    await _cartRef(userId).doc(productId.toString()).delete();
  }

  Future<void> incrementQuantity(int productId, String userId) async {
    final item = _items[productId];
    if (item != null) {
      item.increment();
      await _saveItem(userId, item);
    }
  }

  Future<void> decrementQuantity(int productId, String userId) async {
    final item = _items[productId];
    if (item != null && item.quantity > 1) {
      item.decrement();
      await _saveItem(userId, item);
    }
  }

  Future<void> updateQuantity(
      int productId,
      int quantity,
      String userId,
      ) async {
    final item = _items[productId];
    if (item != null && quantity > 0) {
      item.quantity = quantity;
      await _saveItem(userId, item);
    }
  }

  Future<void> clear(String userId) async {
    final snapshot = await _cartRef(userId).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    _items.clear();
  }

  void clearLocalState() {
    _items.clear();
  }

  Map<String, dynamic> _productToMap(Product product) {
    return {
      'id': product.id,
      'title': product.title,
      'description': product.description,
      'category': product.category,
      'price': product.price,
      'discountPercentage': product.discountPercentage,
      'rating': product.rating,
      'stock': product.stock,
      'brand': product.brand,
      'thumbnail': product.thumbnail,
      'images': product.images,
    };
  }
}