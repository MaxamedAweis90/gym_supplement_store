import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_supplement_store/providers/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedAddress = 'home';
  String _selectedPayment = 'credit_card';

  // Address state
  Map<String, Map<String, String>> _addresses = {
    'home': {
      'name': 'Home',
      'phone': '+251 988 888 888',
      'address': '17th Chaudhary Dhaba Delhi',
    },
    'office': {
      'name': 'Office',
      'phone': '+251 911 555 0115',
      'address': '25B Street Idu Salder musq',
    },
  };

  void _editAddress(String key) async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final nameController = TextEditingController(
          text: _addresses[key]!['name'],
        );
        final phoneController = TextEditingController(
          text: _addresses[key]!['phone'],
        );
        final addressController = TextEditingController(
          text: _addresses[key]!['address'],
        );
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit ${_addresses[key]!['name']} Address',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
                minLines: 1,
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop({
                      'name': nameController.text,
                      'phone': phoneController.text,
                      'address': addressController.text,
                    });
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        _addresses[key] = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: Text(
            'Checkout',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                children: [
                  Text(
                    'Delivery to',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAddressOption(
                    context,
                    value: 'home',
                    title: _addresses['home']!['name']!,
                    subtitle:
                        '${_addresses['home']!['phone']!}\n${_addresses['home']!['address']!}',
                    selected: _selectedAddress == 'home',
                    onTap: () => setState(() => _selectedAddress = 'home'),
                  ),
                  const SizedBox(height: 10),
                  _buildAddressOption(
                    context,
                    value: 'office',
                    title: _addresses['office']!['name']!,
                    subtitle:
                        '${_addresses['office']!['phone']!}\n${_addresses['office']!['address']!}',
                    selected: _selectedAddress == 'office',
                    onTap: () => setState(() => _selectedAddress = 'office'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Payment method',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentOption(
                    context,
                    value: 'credit_card',
                    icon: Icons.credit_card,
                    label: 'Credit Card',
                    selected: _selectedPayment == 'credit_card',
                    onTap: () =>
                        setState(() => _selectedPayment = 'credit_card'),
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    context,
                    value: 'paypal',
                    icon: Icons.account_balance_wallet,
                    label: 'PayPal',
                    selected: _selectedPayment == 'paypal',
                    onTap: () => setState(() => _selectedPayment = 'paypal'),
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    context,
                    value: 'google_pay',
                    icon: Icons.account_balance,
                    label: 'Google Pay',
                    selected: _selectedPayment == 'google_pay',
                    onTap: () =>
                        setState(() => _selectedPayment = 'google_pay'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delivery fee', style: theme.textTheme.bodyMedium),
                      Text(
                        '\$${cartProvider.deliveryFee.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sub total', style: theme.textTheme.bodyMedium),
                      Text(
                        '\$${cartProvider.subtotal.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${cartProvider.total.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: cartProvider.items.isEmpty
                          ? null
                          : () async {
                              final theme = Theme.of(context);
                              final user = FirebaseAuth.instance.currentUser;
                              final orderData = {
                                'userId': user?.uid,
                                'userEmail': user?.email,
                                'items': cartProvider.items
                                    .map(
                                      (item) => {
                                        'id': item.id,
                                        'name': item.name,
                                        'imageUrl': item.imageUrl,
                                        'price': item.price,
                                        'discountPrice': item.discountPrice,
                                        'quantity': item.quantity,
                                      },
                                    )
                                    .toList(),
                                'address': _addresses[_selectedAddress],
                                'paymentMethod': _selectedPayment,
                                'subtotal': cartProvider.subtotal,
                                'deliveryFee': cartProvider.deliveryFee,
                                'total': cartProvider.total,
                                'status': 'pending',
                                'createdAt': FieldValue.serverTimestamp(),
                              };
                              // Save order to Firestore
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .add(orderData);
                              final result = await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: theme.colorScheme.primary,
                                            size: 64,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Payment Successful!',
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Your order has been placed.',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Total Paid:',
                                                style:
                                                    theme.textTheme.bodyMedium,
                                              ),
                                              Text(
                                                '\$${cartProvider.total.toStringAsFixed(2)}',
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text(
                                                'Return to Home',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                              if (result == true) {
                                cartProvider.clearCart();
                                Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst);
                              }
                            },
                      child: const Text(
                        'Payments',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressOption(
    BuildContext context, {
    required String value,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: selected ? 2 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editAddress(value),
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required String value,
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: selected ? 2 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
