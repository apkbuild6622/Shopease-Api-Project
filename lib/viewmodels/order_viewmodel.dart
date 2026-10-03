import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../repositories/order_repository.dart';
import '../services/auth_service.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _repository;
  final AuthService _authService;

  OrderViewModel({
    required OrderRepository repository,
    required AuthService authService,
  })  : _repository = repository,
        _authService = authService;

  List<Order> _orders = [];
  List<Order> get orders => List.unmodifiable(_orders);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isEmpty => _orders.isEmpty;
  bool get isNotEmpty => _orders.isNotEmpty;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _orders = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _repository.getUserOrders(userId);
    } catch (e) {
      _errorMessage = 'Failed to load orders';
      _orders = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Order> createOrder({
    required List<CartItem> cartItems,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    String paymentMethod = 'cod',
  }) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final orderItems =
    cartItems.map((ci) => OrderItem.fromCartItem(ci)).toList();

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

    await _repository.addOrder(order, userId);

    _orders.insert(0, order);
    notifyListeners();

    return order;
  }

  void clearLocalState() {
    _orders = [];
    notifyListeners();
  }

  String _generateOrderId() {
    final now = DateTime.now();
    final datePart = '${now.year}${_pad(now.month)}${_pad(now.day)}';
    final randomPart = (1000 + (now.microsecond % 9000)).toString();
    return 'ORD-$datePart-$randomPart';
  }

  String _pad(int value) => value.toString().padLeft(2, '0');
}