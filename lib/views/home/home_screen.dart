import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../product_details/product_details_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/category_chips.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/product_grid.dart';
import 'widgets/promo_carousel.dart';

class HomeScreen extends StatefulWidget {
  final bool showAppBar;
  final bool showDrawer;

  const HomeScreen({
    super.key,
    this.showAppBar = true,
    this.showDrawer = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ProductViewModel>();
      vm.fetchProducts();
      vm.fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<ProductViewModel>().loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      AppConstants.searchDebounceDuration,
          () {
        if (!mounted) return;
        context.read<ProductViewModel>().search(value);
      },
    );
  }

  void _onSearchSubmitted(String value) {
    _searchDebounce?.cancel();
    context.read<ProductViewModel>().search(value);
  }

  void _onSearchClear() {
    _searchDebounce?.cancel();
    _searchController.clear();
    context.read<ProductViewModel>().clearSearch();
  }

  void _onCategorySelected(String category) {
    _searchDebounce?.cancel();
    _searchController.clear();
    context.read<ProductViewModel>().selectCategory(category);
  }

  void _onProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }

  void _onAddToCart(Product product) {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    context.read<CartViewModel>().addToCart(product);

    messenger.showSnackBar(
      SnackBar(
        content: Text('${product.title} added to cart'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
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

  void _onDrawerNavigate(String route) {
    switch (route) {
      case 'home':
        break;
      case 'cart':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
        break;
      case 'orders':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrdersScreen()),
        );
        break;
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar
          ? HomeAppBar(
        onCartTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CartScreen(),
            ),
          );
        },
      )
          : null,
      drawer:
      widget.showDrawer ? AppDrawer(onNavigate: _onDrawerNavigate) : null,
      body: Consumer<ProductViewModel>(
        builder: (context, vm, _) {
          final promos = vm.promotionalProducts;
          final showPromo =
              vm.searchQuery.isEmpty && vm.selectedCategory == 'All';

          return RefreshIndicator(
            onRefresh: vm.refresh,
            color: AppColors.primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: HomeSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onSubmitted: _onSearchSubmitted,
                    onClear: _onSearchClear,
                  ),
                ),
                if (showPromo)
                  SliverToBoxAdapter(
                    child: PromoCarousel(products: promos),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: Text(
                      'Categories',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: CategoryChips(
                    categories: vm.categories,
                    selected: vm.selectedCategory,
                    onSelected: _onCategorySelected,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: Text(
                      _buildProductsHeader(vm),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                _buildProductSliver(vm),
              ],
            ),
          );
        },
      ),
    );
  }

  String _buildProductsHeader(ProductViewModel vm) {
    if (vm.searchQuery.isNotEmpty) {
      return 'Results for "${vm.searchQuery}"';
    }
    if (vm.selectedCategory != 'All') {
      return _formatCategory(vm.selectedCategory);
    }
    return 'Featured Products';
  }

  String _formatCategory(String category) {
    return category
        .split('-')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Widget _buildProductSliver(ProductViewModel vm) {
    if (vm.isLoading) {
      return const SliverToBoxAdapter(
        child: ProductListSkeleton(),
      );
    }

    if (vm.hasError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorView(
          message: vm.errorMessage ?? 'Something went wrong',
          onRetry: () => vm.refresh(),
        ),
      );
    }

    if (vm.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyView(
          title: vm.searchQuery.isNotEmpty
              ? 'No Results Found'
              : 'No Products',
          message: vm.searchQuery.isNotEmpty
              ? 'Try searching for something else.'
              : 'There are no products to display.',
          icon: vm.searchQuery.isNotEmpty
              ? Icons.search_off_rounded
              : Icons.inventory_2_outlined,
          onAction: vm.searchQuery.isNotEmpty ? _onSearchClear : null,
          actionLabel: vm.searchQuery.isNotEmpty ? 'Clear Search' : null,
        ),
      );
    }

    return ProductGridSliver(
      products: vm.products,
      isLoadingMore: vm.isLoadingMore,
      onProductTap: _onProductTap,
      onAddToCart: _onAddToCart,
    );
  }
}