import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../viewmodels/cart_viewmodel.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            _buildCartItem(),
            BottomNavigationBarItem(
              icon: _ordersIcon(false),
              activeIcon: _ordersIcon(true),
              label: 'Orders',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildCartItem() {
    return BottomNavigationBarItem(
      icon: Consumer<CartViewModel>(
        builder: (context, cart, _) {
          return _BadgeIconWrapper(
            count: cart.totalQuantity,
            child: const Icon(Icons.shopping_cart_outlined),
          );
        },
      ),
      activeIcon: Consumer<CartViewModel>(
        builder: (context, cart, _) {
          return _BadgeIconWrapper(
            count: cart.totalQuantity,
            child: const Icon(Icons.shopping_cart_rounded),
          );
        },
      ),
      label: 'Cart',
    );
  }

  Widget _ordersIcon(bool active) {
    return Icon(
      active ? Icons.receipt_long_rounded : Icons.receipt_long_outlined,
    );
  }
}

class _BadgeIconWrapper extends StatelessWidget {
  final int count;
  final Widget child;

  const _BadgeIconWrapper({
    required this.count,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -8,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            constraints: const BoxConstraints(minWidth: 16),
            decoration: BoxDecoration(
              color: AppColors.discountBadge,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Text(
              count > 99 ? '99+' : count.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}