import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_formatters.dart';

class CartSummary extends StatelessWidget {
  final double subtotal;
  final double savings;
  final double deliveryCharge;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.savings,
    this.deliveryCharge = AppConstants.deliveryCharge,
  });

  double get total => subtotal + deliveryCharge;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: AppTextStyles.subHeading),
          const SizedBox(height: 16),
          _row('Subtotal', AppFormatters.formatPrice(subtotal)),
          if (savings > 0) ...[
            const SizedBox(height: 10),
            _row(
              'You Save',
              '- ${AppFormatters.formatPrice(savings)}',
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: 10),
          _row(
            'Delivery',
            AppFormatters.formatPrice(deliveryCharge),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.subHeading),
              Text(
                AppFormatters.formatPrice(total),
                style: AppTextStyles.price.copyWith(fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}