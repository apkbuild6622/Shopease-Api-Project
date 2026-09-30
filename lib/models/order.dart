import 'order_item.dart';

enum OrderStatus { pending, shipped, delivered, cancelled }

class Order {
  final String id;
  final DateTime date;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryCharge;
  final double total;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String paymentMethod;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.total,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.paymentMethod,
    this.status = OrderStatus.pending,
  });

  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity);

  int get uniqueItemCount => items.length;

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}