import 'package:flutter/material.dart';
import 'package:app1/models/address.dart';
import 'package:app1/services/order_service.dart';
import 'package:app1/services/address_service.dart';
import 'package:app1/models/payment_method.dart';
import 'package:app1/services/payment_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/l10n/app_localizations.dart';
import 'khqr_payment_page.dart';
import '../widgets/checkout_address_section.dart';
import '../widgets/checkout_items_list.dart';
import '../widgets/checkout_payment_selector.dart';
import '../widgets/checkout_price_summary.dart';
import '../widgets/checkout_bottom_bar.dart';
import 'package:app1/features/settings/address/presentation/pages/address_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<dynamic> selectedItems;
  final int userId;

  const CheckoutPage({
    super.key,
    required this.selectedItems,
    required this.userId,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isProcessing = false;
  bool _isLoading = true;
  List<Address> _addresses = [];
  List<PaymentMethod> _paymentMethods = [];
  List<dynamic> _stores = [];
  Address? _selectedAddress;
  String _selectedPaymentMethod = 'cod';
  double _walletBalance = 0.0;
  final Map<String, int> _selectedDeliveryMethods = {}; // {storeId: methodId}

  // Coupon variables
  final TextEditingController _couponController = TextEditingController();
  String? _appliedCouponCode;
  double _discountAmount = 0.0;
  bool _isValidatingCoupon = false;

  static const Color lazadaOrange = Color(0xFFFF6600);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final List<int> itemIds =
          widget.selectedItems.map((e) => e['id'] as int).toList();

      final results = await Future.wait([
        AddressService.getAddresses(widget.userId),
        PaymentService.getPaymentMethods(),
        OrderService.getCheckoutData(widget.userId, itemIds),
      ]);

      final addressData = results[0] as List<dynamic>;
      final paymentData = results[1] as List<PaymentMethod>;
      final checkoutData = results[2] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _addresses = addressData
              .where((e) => e != null && e is Map<String, dynamic>)
              .map((e) => Address.fromJson(e as Map<String, dynamic>))
              .toList();
          _selectedAddress = _addresses.isNotEmpty
              ? _addresses.firstWhere((a) => a.isDefault,
                  orElse: () => _addresses.first)
              : null;

          _stores = checkoutData['stores'] ?? [];
          _walletBalance =
              double.tryParse(checkoutData['wallet']['balance'].toString()) ??
                  0.0;

          for (var store in _stores) {
            final methods = store['deliveryMethods'] as List<dynamic>;
            if (methods.isNotEmpty) {
              _selectedDeliveryMethods[store['id'].toString()] =
                  methods.first['id'] as int;
            }
          }

          final walletMethod = PaymentMethod(
            id: 'user_wallet',
            name: 'My Wallet',
            description: 'Balance: \$${_walletBalance.toStringAsFixed(2)}',
            icon: 'wallet_rounded',
            color: _walletBalance > 0 ? 'orange' : 'grey',
          );
          _paymentMethods = [walletMethod, ...paymentData];

          if (_walletBalance > 0) {
            _selectedPaymentMethod = 'user_wallet';
          } else if (paymentData.isNotEmpty) {
            _selectedPaymentMethod = paymentData.first.id.toString();
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Checkout Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _calculateSubtotal() {
    double total = 0;
    for (var store in _stores) {
      final items = store['items'] as List<dynamic>;
      for (var item in items) {
        final price = item['productVariant'] != null
            ? double.parse(item['productVariant']['price'].toString())
            : double.parse(item['product']['price'].toString());
        total += price * (item['quantity'] as int);
      }
    }
    return total;
  }

  double _calculateShipping() {
    double total = 0;
    for (var store in _stores) {
      final storeId = store['id'].toString();
      final selectedId = _selectedDeliveryMethods[storeId];
      final methods = store['deliveryMethods'] as List<dynamic>;
      final method = methods.firstWhere((m) => m['id'] == selectedId,
          orElse: () => methods.isNotEmpty ? methods.first : null);
      if (method != null) {
        total += double.parse(method['price'].toString());
      }
    }
    return total;
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _calculateShipping() - _discountAmount;
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isValidatingCoupon = true);

    try {
      final result = await OrderService.validateCoupon(code);
      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _appliedCouponCode = code;
            _discountAmount =
                double.tryParse(result['coupon']['discount'].toString()) ?? 0.0;
            _isValidatingCoupon = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Coupon applied!'),
                backgroundColor: Colors.green),
          );
        } else {
          setState(() => _isValidatingCoupon = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(result['message'] ?? 'Invalid coupon'),
                backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isValidatingCoupon = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCouponCode = null;
      _discountAmount = 0.0;
      _couponController.clear();
    });
  }

  Future<void> _handlePlaceOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shipping address')),
      );
      return;
    }

    final totalToPay = _calculateTotal();

    if (_selectedPaymentMethod == 'user_wallet' &&
        _walletBalance < totalToPay) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Insufficient wallet balance. Need \$${totalToPay.toStringAsFixed(2)}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod.toLowerCase().contains('khqr')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KHQRPaymentPage(
            amount: totalToPay,
            orderId: "TEMP-${DateTime.now().millisecondsSinceEpoch}",
            onPaymentSuccess: () {
              Navigator.pop(context);
              _executePlaceOrder();
            },
          ),
        ),
      );
      return;
    }
    _executePlaceOrder();
  }

  Future<void> _executePlaceOrder() async {
    setState(() => _isProcessing = true);
    try {
      final List<int> itemIds =
          widget.selectedItems.map((e) => e['id'] as int).toList();

      await OrderService.placeOrder(
        widget.userId,
        _selectedAddress!.id!,
        _selectedPaymentMethod,
        selectedCartItemIds: itemIds,
        storeDeliveryMethods: _selectedDeliveryMethods,
        couponCode: _appliedCouponCode,
      );

      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Text(t.translate('order_successful'),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(t.translate('order_success_msg'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: lazadaOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(t.translate('go_to_dashboard'),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtotal = _calculateSubtotal();
    final shipping = _calculateShipping();
    final total = _calculateTotal();

    return Scaffold(
      backgroundColor: isDark
          ? const Color.fromARGB(255, 35, 35, 35)
          : const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: Text(t.translate('checkout_confirmation'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: lazadaOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel(t.translate('shipping_to')),
                  CheckoutAddressSection(
                    selectedAddress: _selectedAddress,
                    onTap: _showAddressPicker,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  ..._buildStoreSections(isDark, t),
                  const SizedBox(height: 24),
                  _buildSectionLabel("Voucher / Coupon"),
                  _buildCouponSection(isDark),
                  const SizedBox(height: 24),
                  _buildSectionLabel(t.translate('payment_method')),
                  CheckoutPaymentSelector(
                    paymentMethods: _paymentMethods,
                    selectedPaymentMethod: _selectedPaymentMethod,
                    onChanged: (id) =>
                        setState(() => _selectedPaymentMethod = id),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionLabel(t.translate('billing_summary')),
                  CheckoutPriceSummary(
                    subtotal: subtotal,
                    shipping: shipping,
                    discount: _discountAmount,
                    total: total,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
      bottomSheet: CheckoutBottomBar(
        total: total,
        isProcessing: _isProcessing,
        onPlaceOrder: _handlePlaceOrder,
        isDark: isDark,
      ),
    );
  }

  Widget _buildCouponSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: "Enter coupon code",
                    hintStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  enabled: _appliedCouponCode == null,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isValidatingCoupon
                      ? null
                      : (_appliedCouponCode == null
                          ? _applyCoupon
                          : _removeCoupon),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _appliedCouponCode == null
                        ? lazadaOrange
                        : Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isValidatingCoupon
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_appliedCouponCode == null ? "Apply" : "Remove"),
                ),
              ),
            ],
          ),
          if (_appliedCouponCode != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(
                  "Coupon applied: $_appliedCouponCode (-\$${_discountAmount.toStringAsFixed(2)})",
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildStoreSections(bool isDark, dynamic t) {
    return _stores.map((store) {
      final storeId = store['id'].toString();
      final methods = store['deliveryMethods'] as List<dynamic>;
      final selectedId = _selectedDeliveryMethods[storeId];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
            child: Row(
              children: [
                const Icon(Icons.storefront, size: 16, color: lazadaOrange),
                const SizedBox(width: 8),
                Text(
                  store['name'].toString().toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: lazadaOrange,
                      letterSpacing: 1.1),
                ),
              ],
            ),
          ),
          CheckoutItemsList(
            selectedItems: store['items'],
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SHIPPING OPTION",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(height: 8),
                ...methods.map((m) {
                  final isSelected = m['id'] == selectedId;
                  return InkWell(
                    onTap: () => setState(
                        () => _selectedDeliveryMethods[storeId] = m['id']),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected ? lazadaOrange : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m['name'],
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black)),
                                Text("Estimated 2-3 days",
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                          Text(
                              "\$${double.parse(m['price'].toString()).toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: lazadaOrange)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
            letterSpacing: 1.2),
      ),
    );
  }

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Text("Select Shipping Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            if (_addresses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Text("No addresses found. Please add one in Profile."),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final addr = _addresses[index];
                    final isSelected = _selectedAddress?.id == addr.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? lazadaOrange : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(addr.fullName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text("${addr.addressLine1}, ${addr.city}"),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: lazadaOrange)
                            : null,
                        onTap: () {
                          setState(() => _selectedAddress = addr);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddressListPage()),
                    ).then((_) => _loadInitialData());
                  },
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text("Manage Addresses"),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
