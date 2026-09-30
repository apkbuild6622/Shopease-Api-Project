import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/app_formatters.dart';
import '../models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Offset? _tapStartPosition;

  void _handleTapDown(TapDownDetails details) {
    _tapStartPosition = details.globalPosition;
  }

  void _handleTapUp(TapUpDetails details) {
    if (_tapStartPosition == null) return;
    final distance = (details.globalPosition - _tapStartPosition!).distance;
    if (distance < 10) {
      widget.onTap?.call();
    }
    _tapStartPosition = null;
  }

  void _handleTapCancel() {
    _tapStartPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildImage(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitle(),
                const SizedBox(height: 4),
                _buildRating(),
                const SizedBox(height: 6),
                _buildPriceRow(),
                const SizedBox(height: 10),
                _buildAddButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: widget.product.thumbnail,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.divider,
                child: const Center(
                  child: Icon(Icons.image_outlined, color: Colors.grey),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.divider,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        if (widget.product.isDiscounted)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.discountBadge,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '-${widget.product.discountPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.product.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.body.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        height: 1.2,
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        const Icon(
          Icons.star_rounded,
          size: 13,
          color: AppColors.ratingStar,
        ),
        const SizedBox(width: 2),
        Text(
          widget.product.rating.toStringAsFixed(1),
          style: AppTextStyles.caption.copyWith(fontSize: 11),
        ),
        const SizedBox(width: 4),
        Text(
          '(${widget.product.stock})',
          style: AppTextStyles.caption.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            AppFormatters.formatPrice(widget.product.discountedPrice),
            style: AppTextStyles.price.copyWith(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.product.isDiscounted)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              AppFormatters.formatPrice(widget.product.price),
              style: AppTextStyles.oldPrice.copyWith(fontSize: 10),
            ),
          ),
      ],
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 30,
      child: ElevatedButton.icon(
        onPressed: widget.onAddToCart,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(Icons.add_shopping_cart, size: 14),
        label: const Text(
          'Add',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}