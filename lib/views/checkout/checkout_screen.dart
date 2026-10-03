import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/utils/feedback_helper.dart';
import '../../models/order.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import 'widgets/checkout_form.dart';
import 'widgets/order_items_preview.dart';
import 'widgets/payment_method_selector.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _paymentMethod = 'cod';
  bool _isPlacing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillFromProfile();
    });
  }

  void _prefillFromProfile() {
    final profile = context.read<ProfileViewModel>().profile;
    if (profile == null) return;

    _nameController.text = profile.name;
    _phoneController.text = profile.phone;
    _addressController.text = profile.address;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_isPlacing) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartViewModel>();
    final orderVM = context.read<OrderViewModel>();

    if (cart.isEmpty) {
      FeedbackHelper.showError(context, 'Your cart is empty.');
      return;
    }

    setState(() {
      _isPlacing = true;
    });

    try {
      final order = await orderVM.createOrder(
        cartItems: cart.items,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        customerAddress: _addressController.text.trim(),
        paymentMethod: _paymentMethod,
      );

      if (!mounted) return;

      setState(() {
        _isPlacing = false;
      });

      await cart.clearCart();

      if (!mounted) return;

      _showSuccessDialog(order);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isPlacing = false;
      });

      FeedbackHelper.showError(context, 'Failed to place order. Try again.');
    }
  }

  void _showSuccessDialog(Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 56,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Order Placed!',
                style: AppTextStyles.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your order #${_shortId(order.id)} has been placed successfully.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _goToOrdersTab();
                },
                child: const Text('View Orders'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _goHome();
                },
                child: const Text('Continue Shopping'),
              ),
            ),
          ],
        );
      },
    );
  }

  String _shortId(String fullId) {
    final parts = fullId.split('-');
    if (parts.length >= 3) return parts.last;
    return fullId;
  }

  void _goToOrdersTab() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Consumer<CartViewModel>(
        builder: (context, cart, _) {
          if (cart.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Your cart is empty.'),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckoutForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  phoneController: _phoneController,
                  addressController: _addressController,
                ),
                const SizedBox(height: 14),
                OrderItemsPreview(items: cart.items),
                const SizedBox(height: 14),
                PaymentMethodSelector(
                  selected: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                _buildSummary(cart),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<CartViewModel>(
        builder: (context, cart, _) {
          if (cart.isEmpty) return const SizedBox.shrink();

          final total = cart.subtotal + AppConstants.deliveryCharge;

          return Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total', style: AppTextStyles.caption),
                      Text(
                        AppFormatters.formatPrice(total),
                        style: AppTextStyles.price.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isPlacing ? null : _placeOrder,
                      icon: _isPlacing
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(
                        Icons.check_circle_outline,
                        size: 20,
                      ),
                      label: Text(
                        _isPlacing ? 'Placing Order...' : 'Place Order',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummary(CartViewModel cart) {
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
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text('Order Summary', style: AppTextStyles.subHeading),
            ],
          ),
          const SizedBox(height: 12),
          _summaryRow('Subtotal', AppFormatters.formatPrice(cart.subtotal)),
          if (cart.savings > 0)
            _summaryRow(
              'Discount',
              '- ${AppFormatters.formatPrice(cart.savings)}',
              valueColor: AppColors.success,
            ),
          _summaryRow(
            'Delivery',
            AppFormatters.formatPrice(AppConstants.deliveryCharge),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.subHeading),
              Text(
                AppFormatters.formatPrice(
                  cart.subtotal + AppConstants.deliveryCharge,
                ),
                style: AppTextStyles.price.copyWith(fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
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
      ),
    );
  }
}