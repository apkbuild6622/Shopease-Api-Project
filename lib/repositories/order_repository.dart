import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';
import '../models/order_item.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ordersRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders');
  }

  Future<void> addOrder(Order order, String userId) async {
    await _ordersRef(userId).doc(order.id).set({
      'id': order.id,
      'date': Timestamp.fromDate(order.date),
      'items': order.items
          .map((i) => {
        'productId': i.productId,
        'title': i.title,
        'thumbnail': i.thumbnail,
        'unitPrice': i.unitPrice,
        'originalUnitPrice': i.originalUnitPrice,
        'quantity': i.quantity,
      })
          .toList(),
      'subtotal': order.subtotal,
      'deliveryCharge': order.deliveryCharge,
      'total': order.total,
      'customerName': order.customerName,
      'customerPhone': order.customerPhone,
      'customerAddress': order.customerAddress,
      'paymentMethod': order.paymentMethod,
      'status': order.status.name,
    });
  }

  Future<List<Order>> getUserOrders(String userId) async {
    final snapshot = await _ordersRef(userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => _orderFromDoc(doc.data())).toList();
  }

  Order _orderFromDoc(Map<String, dynamic> data) {
    final items = (data['items'] as List)
        .map((i) => OrderItem(
      productId: i['productId'] as int,
      title: i['title'] as String,
      thumbnail: i['thumbnail'] as String,
      unitPrice: (i['unitPrice'] as num).toDouble(),
      originalUnitPrice: (i['originalUnitPrice'] as num).toDouble(),
      quantity: i['quantity'] as int,
    ))
        .toList();

    return Order(
      id: data['id'] as String,
      date: (data['date'] as Timestamp).toDate(),
      items: items,
      subtotal: (data['subtotal'] as num).toDouble(),
      deliveryCharge: (data['deliveryCharge'] as num).toDouble(),
      total: (data['total'] as num).toDouble(),
      customerName: data['customerName'] as String,
      customerPhone: data['customerPhone'] as String,
      customerAddress: data['customerAddress'] as String,
      paymentMethod: data['paymentMethod'] as String,
      status: OrderStatus.values.firstWhere(
            (s) => s.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
    );
  }

  Future<void> clearUserOrders(String userId) async {
    final snapshot = await _ordersRef(userId).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}