import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_formatters.dart';

class DetailsBottomBar extends StatelessWidget {
  final double totalPrice;
  final VoidCallback? onAddToCart;
  final bool isOutOfStock;

  const DetailsBottomBar({
    super.key,
    required this.totalPrice,
    this.onAddToCart,
    this.isOutOfStock = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total', style: AppTextStyles.caption),
                Text(
                  AppFormatters.formatPrice(totalPrice),
                  style: AppTextStyles.price.copyWith(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isOutOfStock ? null : onAddToCart,
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: Text(
                  isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}