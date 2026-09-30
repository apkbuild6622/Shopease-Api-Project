import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_formatters.dart';
import '../../models/cart_item.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../product_details/product_details_screen.dart';
import 'widgets/cart_empty_view.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_summary.dart';
import '../checkout/checkout_screen.dart';
import '../../core/utils/feedback_helper.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback? onStartShopping;
  final bool showAppBar;

  const CartScreen({
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
        title: const Text('My Cart'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      )
          : null,
      body: Consumer<CartViewModel>(
        builder: (context, cart, _) {
          if (cart.isEmpty) {
            return CartEmptyView(
              onStartShopping: onStartShopping ?? () => Navigator.pop(context),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    // inside ListView.builder itemBuilder:
                    return CartItemCard(
                      item: item,
                      onIncrement: () => cart.increment(item.productId),
                      onDecrement: () => cart.decrement(item.productId),
                      onRemove: () => _confirmRemove(context, cart, item),
                      onTap: () => _openProductDetails(context, item),
                    );
                  },
                ),
              ),
              _buildBottomSection(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, CartViewModel cart) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CartSummary(
              subtotal: cart.subtotal,
              savings: cart.savings,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _onCheckout(context),
                  icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                  label: Text(
                    'Checkout  •  ${AppFormatters.formatPrice(cart.subtotal + 50)}',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _openProductDetails(BuildContext context, CartItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: item.product),
      ),
    );
  }
  void _onCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CheckoutScreen(),
      ),
    );
  }
  void _confirmRemove(
      BuildContext context,
      CartViewModel cart,
      CartItem item,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Remove Item?'),
          content: Text(
            'Remove "${item.product.title}" from your cart?',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                cart.removeFromCart(item.productId);
                FeedbackHelper.showRemoved(
                  context,
                  '${item.product.title} removed',
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}