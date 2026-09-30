import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../viewmodels/cart_viewmodel.dart';
import '../../../widgets/cart_badge_icon.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onCartTap;

  const HomeAppBar({
    super.key,
    this.onCartTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 4,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Color(0xFF2E7D32),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      actions: [
        Consumer<CartViewModel>(
          builder: (context, cart, _) {
            return CartBadgeIcon(
              count: cart.totalQuantity,
              onTap: onCartTap,
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}