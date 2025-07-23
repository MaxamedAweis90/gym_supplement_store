import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkout.dart';

class OrderPreviewScreen extends StatelessWidget {
  const OrderPreviewScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchProductDetails(
    List cartItems,
  ) async {
    if (cartItems.isEmpty) return [];
    final firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> result = [];
    for (var item in cartItems) {
      try {
        final doc = await firestore.collection('products').doc(item.id).get();
        if (doc.exists) {
          result.add({...doc.data()!, 'id': doc.id, 'quantity': item.quantity});
        } else {
          // Product not found, fallback to cart data
          result.add({
            'id': item.id,
            'name': item.name,
            'imageUrl': item.imageUrl,
            'price': item.price,
            'discountPrice': item.discountPrice,
            'quantity': item.quantity,
            'notFound': true,
          });
        }
      } catch (e) {
        // On error, fallback to cart data
        result.add({
          'id': item.id,
          'name': item.name,
          'imageUrl': item.imageUrl,
          'price': item.price,
          'discountPrice': item.discountPrice,
          'quantity': item.quantity,
          'notFound': true,
        });
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.colorScheme.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Order Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 18, top: 8),
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: theme.colorScheme.onBackground,
                    size: 28,
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.background,
                          width: 1.5,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchProductDetails(cartItems),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final products = snapshot.data ?? [];
                    return ListView(
                      children: [
                        ...products.map(
                          (item) => Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowColor.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${item['quantity']}',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['imageUrl'] ?? '',
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 32,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.2),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item['name'] ?? 'Unknown',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                theme.colorScheme.onBackground,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${((item['discountPrice'] ?? item['price']) * item['quantity']).toStringAsFixed(2)}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onBackground,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Order summary
                        Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 18),
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 18,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sub total',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  Text(
                                    '\$${cartProvider.subtotal.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Delivery',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  Text(
                                    '\$${cartProvider.deliveryFee.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                              const Divider(height: 22, thickness: 1),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '\$${cartProvider.total.toStringAsFixed(2)}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: cartItems.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutScreen(),
                            ),
                          );
                        },
                  child: Text(
                    'Proceed to Checkout',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
