import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/order_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../widgets/cart_badge_icon.dart';
import 'cart/cart_screen.dart';
import 'home/home_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = const [
      HomeScreen(showAppBar: false, showDrawer: false),
      CartScreen(showAppBar: false),
      OrdersScreen(showAppBar: false),
      ProfileScreen(showAppBar: false),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final cart = context.read<CartViewModel>();
    final orders = context.read<OrderViewModel>();
    final profile = context.read<ProfileViewModel>();

    await Future.wait([
      cart.loadCart(),
      orders.fetchOrders(),
      profile.loadProfile(),
    ]);
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  void _onDrawerNavigate(String route) {
    switch (route) {
      case 'home':
        _onTabTap(0);
        break;
      case 'cart':
        _onTabTap(1);
        break;
      case 'orders':
        _onTabTap(2);
        break;
      case 'profile':
        _onTabTap(3);
        break;
      case 'about':
        showAboutDialog(
          context: context,
          applicationName: 'ShopEase',
          applicationVersion: '1.0.0',
          applicationLegalese: 'Learning project',
        );
        break;
    }
  }

  String _currentTitle() {
    switch (_currentIndex) {
      case 0:
        return AppConstants.appName;
      case 1:
        return 'My Cart';
      case 2:
        return 'My Orders';
      case 3:
        return 'Profile';
      default:
        return AppConstants.appName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 4,
        title: _buildAppBarTitle(),
        actions: _buildAppBarActions(),
      ),
      drawer: AppDrawer(onNavigate: _onDrawerNavigate),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }

  Widget _buildAppBarTitle() {
    if (_currentIndex == 0) {
      return Row(
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
      );
    }

    return Text(
      _currentTitle(),
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      if (_currentIndex == 0)
        Consumer<CartViewModel>(
          builder: (context, cart, _) {
            return CartBadgeIcon(
              count: cart.totalQuantity,
              onTap: () => _onTabTap(1),
            );
          },
        ),
      const SizedBox(width: 4),
    ];
  }
}