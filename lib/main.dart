import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'repositories/product_repository.dart';
import 'repositories/cart_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/profile_repository.dart';
import 'viewmodels/product_viewmodel.dart';
import 'viewmodels/cart_viewmodel.dart';
import 'viewmodels/order_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ShopEaseBootstrap());
}

class ShopEaseBootstrap extends StatefulWidget {
  const ShopEaseBootstrap({super.key});

  @override
  State<ShopEaseBootstrap> createState() => _ShopEaseBootstrapState();
}

class _ShopEaseBootstrapState extends State<ShopEaseBootstrap> {
  late final ApiService _apiService;
  late final AuthService _authService;
  late final ProductRepository _productRepository;
  late final CartRepository _cartRepository;
  late final OrderRepository _orderRepository;
  late final ProfileRepository _profileRepository;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _authService = AuthService();
    _productRepository = ProductRepository(apiService: _apiService);
    _cartRepository = CartRepository();
    _orderRepository = OrderRepository();
    _profileRepository = ProfileRepository();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authService: _authService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductViewModel(repository: _productRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CartViewModel(
            repository: _cartRepository,
            authService: _authService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderViewModel(
            repository: _orderRepository,
            authService: _authService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(
            repository: _profileRepository,
            authService: _authService,
          ),
        ),
      ],
      child: const ShopEaseApp(),
    );
  }
}