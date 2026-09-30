import 'package:flutter/material.dart';
import '../../../models/product.dart';
import '../../../widgets/product_card.dart';

class ProductGridSliver extends StatelessWidget {
  final List<Product> products;
  final bool isLoadingMore;
  final void Function(Product) onProductTap;
  final void Function(Product) onAddToCart;

  const ProductGridSliver({
    super.key,
    required this.products,
    this.isLoadingMore = false,
    required this.onProductTap,
    required this.onAddToCart,
  });

  int _columnsFor(double width) {
    if (width < 600) return 2;
    if (width < 900) return 3;
    return 4;
  }

  double _cardHeightFor(double width) {
    if (width < 600) return 290;
    if (width < 900) return 310;
    return 340;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = _columnsFor(width);
    final cardHeight = _cardHeightFor(width);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          mainAxisExtent: cardHeight,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index >= products.length) {
              return const _LoadingTile();
            }
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => onProductTap(product),
              onAddToCart: () => onAddToCart(product),
            );
          },
          childCount: products.length + (isLoadingMore ? columns : 0),
        ),
      ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}