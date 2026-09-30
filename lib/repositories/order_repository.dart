import '../models/order.dart';

class OrderRepository {
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders.reversed.toList());

  int get orderCount => _orders.length;

  bool get isEmpty => _orders.isEmpty;

  Order? getById(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  void addOrder(Order order) {
    _orders.add(order);
  }

  void clear() {
    _orders.clear();
  }
}