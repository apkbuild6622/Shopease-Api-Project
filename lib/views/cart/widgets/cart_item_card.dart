import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../models/cart_item.dart';
import '../../../widgets/quantity_selector.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const CartItemCard({
    super.key,
    required this.item,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(),
                const SizedBox(width: 12),
                Expanded(child: _buildDetails(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 90,
        height: 90,
        child: CachedNetworkImage(
          imageUrl: item.product.thumbnail,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: AppColors.divider,
          ),
          errorWidget: (_, __, ___) => Container(
            color: AppColors.divider,
            child: const Icon(
              Icons.broken_image_outlined,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          item.product.category,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppFormatters.formatPrice(item.product.discountedPrice),
                    style: AppTextStyles.price.copyWith(fontSize: 15),
                  ),
                  if (item.hasDiscount)
                    Text(
                      AppFormatters.formatPrice(item.product.price),
                      style: AppTextStyles.oldPrice.copyWith(fontSize: 11),
                    ),
                ],
              ),
            ),
            QuantitySelector(
              quantity: item.quantity,
              maxQuantity: item.product.stock,
              onIncrement: onIncrement,
              onDecrement: item.quantity > 1 ? onDecrement : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal',
              style: AppTextStyles.caption,
            ),
            Text(
              AppFormatters.formatPrice(item.subtotal),
              style: AppTextStyles.price.copyWith(fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }
}