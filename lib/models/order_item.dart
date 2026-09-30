import 'cart_item.dart';

class OrderItem {
  final int productId;
  final String title;
  final String thumbnail;
  final double unitPrice;
  final double originalUnitPrice;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.unitPrice,
    required this.originalUnitPrice,
    required this.quantity,
  });

  factory OrderItem.fromCartItem(CartItem cartItem) {
    return OrderItem(
      productId: cartItem.product.id,
      title: cartItem.product.title,
      thumbnail: cartItem.product.thumbnail,
      unitPrice: cartItem.product.discountedPrice,
      originalUnitPrice: cartItem.product.price,
      quantity: cartItem.quantity,
    );
  }

  double get subtotal => unitPrice * quantity;

  double get originalSubtotal => originalUnitPrice * quantity;

  double get savings => originalSubtotal - subtotal;
}