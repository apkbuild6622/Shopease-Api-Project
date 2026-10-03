import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/order_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../views/auth/login_screen.dart';

class AppDrawer extends StatelessWidget {
  final void Function(String route)? onNavigate;

  const AppDrawer({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Consumer<ProfileViewModel>(
            builder: (context, profile, _) => _buildHeader(profile),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildItem(
                  context,
                  icon: Icons.home_outlined,
                  title: 'Home',
                  route: 'home',
                ),
                _buildCartItem(context),
                _buildItem(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'My Orders',
                  route: 'orders',
                ),
                _buildItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Profile',
                  route: 'profile',
                ),
                const Divider(),
                _buildItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  route: 'about',
                ),
                _buildLogoutItem(context),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'v1.0.0 — Learning Project',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ProfileViewModel profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Text(
              profile.initials,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.displayEmail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              profile.hasProfile ? 'Verified Profile' : 'Learning Project',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String route,
      }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body),
      onTap: () {
        Navigator.pop(context);
        onNavigate?.call(route);
      },
    );
  }

  Widget _buildCartItem(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, cart, _) {
        return ListTile(
          leading: const Icon(
            Icons.shopping_cart_outlined,
            color: AppColors.primary,
          ),
          title: Text('Cart', style: AppTextStyles.body),
          trailing: cart.totalQuantity > 0
              ? Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.discountBadge,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              cart.totalQuantity.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : null,
          onTap: () {
            Navigator.pop(context);
            onNavigate?.call('cart');
          },
        );
      },
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.logout_rounded,
        color: AppColors.error,
      ),
      title: Text(
        'Logout',
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
      onTap: () {
        Navigator.pop(context);
        _showLogoutDialog(context);
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    final cartVM = context.read<CartViewModel>();
    final orderVM = context.read<OrderViewModel>();
    final profileVM = context.read<ProfileViewModel>();
    final navigator = Navigator.of(context, rootNavigator: true);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await authVM.signOut();
              } catch (e) {
                debugPrint('SignOut error: $e');
              }

              cartVM.clearLocalState();
              orderVM.clearLocalState();
              profileVM.clearLocalState();

              navigator.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                    (route) => false,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}