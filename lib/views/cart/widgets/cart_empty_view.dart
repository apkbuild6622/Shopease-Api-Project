import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CartEmptyView extends StatelessWidget {
  final VoidCallback? onStartShopping;

  const CartEmptyView({super.key, this.onStartShopping});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Cart is Empty',
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: 10),
            Text(
              'Looks like you haven\'t added anything yet. Start shopping to fill it up!',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStartShopping,
                icon: const Icon(Icons.storefront_outlined, size: 20),
                label: const Text('Start Shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}