import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/order.dart';
import '../../viewmodels/order_viewmodel.dart';
import 'order_details_screen.dart';
import 'widgets/order_card.dart';
import 'widgets/order_empty_view.dart';

class OrdersScreen extends StatelessWidget {
  final VoidCallback? onStartShopping;
  final bool showAppBar;

  const OrdersScreen({
    super.key,
    this.onStartShopping,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
        title: const Text('My Orders'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      )
          : null,
      body: Consumer<OrderViewModel>(
        builder: (context, orders, _) {
          if (orders.isEmpty) {
            return OrderEmptyView(
              onStartShopping:
              onStartShopping ?? () => Navigator.pop(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 400));
            },
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: orders.orders.length,
              itemBuilder: (context, index) {
                final order = orders.orders[index];
                return OrderCard(
                  order: order,
                  onTap: () => _openDetails(context, order),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openDetails(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(order: order),
      ),
    );
  }
}