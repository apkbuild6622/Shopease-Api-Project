import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_formatters.dart';
import '../../models/product.dart';
import 'widgets/details_bottom_bar.dart';
import 'widgets/image_gallery.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../widgets/quantity_selector.dart';
import '../cart/cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  Product get product => widget.product;

  double get _totalPrice => product.discountedPrice * _quantity;

  bool get _isOutOfStock => product.stock <= 0;

  void _incrementQuantity() {
    if (_quantity < product.stock) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _onAddToCart() {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    context.read<CartViewModel>().addToCart(
      product,
      quantity: _quantity,
    );

    messenger.showSnackBar(
      SnackBar(
        content: Text('${product.title} × $_quantity added to cart'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            navigator.push(
              MaterialPageRoute(
                builder: (_) => const CartScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Product Details'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageGallery(
              images: product.images,
              fallbackThumbnail: product.thumbnail,
            ),
            const SizedBox(height: 8),
            _buildInfoCard(),
            const SizedBox(height: 12),
            _buildDescriptionCard(),
            const SizedBox(height: 12),
            _buildQuantityCard(),
          ],
        ),
      ),
      bottomNavigationBar: DetailsBottomBar(
        totalPrice: _totalPrice,
        onAddToCart: _onAddToCart,
        isOutOfStock: _isOutOfStock,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.brand.isNotEmpty && product.brand != 'Unknown')
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                product.brand.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Text(product.title, style: AppTextStyles.heading),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildRating(),
              const SizedBox(width: 12),
              _buildCategoryChip(),
            ],
          ),
          const SizedBox(height: 14),
          _buildPriceRow(),
          const SizedBox(height: 12),
          _buildStockRow(),
        ],
      ),
    );
  }

  Widget _buildRating() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.ratingStar.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded,
              size: 16, color: AppColors.ratingStar),
          const SizedBox(width: 4),
          Text(
            product.rating.toStringAsFixed(1),
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        product.category,
        style: AppTextStyles.caption,
      ),
    );
  }

  Widget _buildPriceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          AppFormatters.formatPrice(product.discountedPrice),
          style: AppTextStyles.price.copyWith(fontSize: 24),
        ),
        if (product.isDiscounted) ...[
          const SizedBox(width: 10),
          Text(
            AppFormatters.formatPrice(product.price),
            style: AppTextStyles.oldPrice.copyWith(fontSize: 15),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.discountBadge,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '-${product.discountPercentage.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStockRow() {
    final isLowStock = product.stock > 0 && product.stock <= 10;
    final isOutOfStock = product.stock <= 0;

    final color = isOutOfStock
        ? AppColors.error
        : isLowStock
        ? AppColors.accent
        : AppColors.success;

    final label = isOutOfStock
        ? 'Out of Stock'
        : isLowStock
        ? 'Only ${product.stock} left in stock'
        : 'In Stock (${product.stock} available)';

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: AppTextStyles.subHeading),
          const SizedBox(height: 10),
          Text(
            product.description,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Quantity', style: AppTextStyles.subHeading),
          QuantitySelector(
            quantity: _quantity,
            maxQuantity: product.stock,
            onIncrement: _incrementQuantity,
            onDecrement: _decrementQuantity,
          ),
        ],
      ),
    );
  }
}