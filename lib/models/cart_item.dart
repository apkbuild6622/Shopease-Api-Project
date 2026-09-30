import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.discountedPrice * quantity;

  double get originalSubtotal => product.price * quantity;

  double get savings => originalSubtotal - subtotal;

  bool get hasDiscount => product.isDiscounted;

  int get productId => product.id;

  void increment() {
    quantity++;
  }

  void decrement() {
    if (quantity > 1) {
      quantity--;
    }
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}