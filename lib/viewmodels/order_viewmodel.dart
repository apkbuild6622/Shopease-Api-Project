import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../repositories/order_repository.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _repository;

  OrderViewModel({required OrderRepository repository})
      : _repository = repository;

  List<Order> get orders => _repository.orders;

  int get orderCount => _repository.orderCount;

  bool get isEmpty => _repository.isEmpty;

  bool get isNotEmpty => !_repository.isEmpty;

  Order? getById(String orderId) => _repository.getById(orderId);

  Order createOrder({
    required List<CartItem> cartItems,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    String paymentMethod = 'cod',
  }) {
    final orderItems = cartItems
        .map((cartItem) => OrderItem.fromCartItem(cartItem))
        .toList();

    final subtotal = orderItems.fold<double>(
      0.0,
          (sum, item) => sum + item.subtotal,
    );

    final order = Order(
      id: _generateOrderId(),
      date: DateTime.now(),
      items: orderItems,
      subtotal: subtotal,
      deliveryCharge: AppConstants.deliveryCharge,
      total: subtotal + AppConstants.deliveryCharge,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      paymentMethod: paymentMethod,
      status: OrderStatus.pending,
    );

    _repository.addOrder(order);
    notifyListeners();

    return order;
  }

  void clearOrders() {
    _repository.clear();
    notifyListeners();
  }

  String _generateOrderId() {
    final now = DateTime.now();
    final datePart =
        '${now.year}${_pad(now.month)}${_pad(now.day)}';
    final randomPart =
    (1000 + (DateTime.now().microsecond % 9000)).toString();
    return 'ORD-$datePart-$randomPart';
  }

  String _pad(int value) => value.toString().padLeft(2, '0');
}