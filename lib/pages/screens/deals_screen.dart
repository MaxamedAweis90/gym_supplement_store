import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_supplement_store/widgets/product_card.dart';
import 'package:gym_supplement_store/pages/screens/product_detail.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  String _selectedFilter = 'all'; // all, 7days, 10days, 30days

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Deals & Discounts',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Filter by: ',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'All Deals', theme),
                        const SizedBox(width: 8),
                        _buildFilterChip('7days', '7 Days', theme),
                        const SizedBox(width: 8),
                        _buildFilterChip('10days', '10 Days', theme),
                        const SizedBox(width: 8),
                        _buildFilterChip('30days', '30 Days', theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Products Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getDealsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading deals',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data?.docs ?? [];

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No deals available',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back later for amazing deals',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    double width = constraints.maxWidth;
                    if (width > 900) {
                      crossAxisCount = 4;
                    } else if (width > 600) {
                      crossAxisCount = 3;
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product =
                            products[index].data() as Map<String, dynamic>;
                        final productId = products[index].id;
                        return ProductCard(
                          imageUrl: product['imageUrl'] ?? '',
                          name: product['name'] ?? 'Product Name',
                          price: (product['price'] ?? 0.0).toDouble(),
                          discountPrice: product['discountPrice'] != null
                              ? (product['discountPrice'] as num).toDouble()
                              : null,
                          rating: product['rating'] != null
                              ? (product['rating'] as num).toDouble()
                              : null,
                          isFavorite: false,
                          onFavoriteToggle: null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(
                                  product: {...product, 'id': productId},
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, ThemeData theme) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getDealsStream() {
    final now = DateTime.now();
    DateTime? startDate;

    switch (_selectedFilter) {
      case '7days':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case '10days':
        startDate = now.subtract(const Duration(days: 10));
        break;
      case '30days':
        startDate = now.subtract(const Duration(days: 30));
        break;
      default:
        startDate = null;
    }

    if (startDate != null) {
      return FirebaseFirestore.instance
          .collection('products')
          .where('discountPrice', isGreaterThan: 0)
          .where('discountStartDate', isGreaterThanOrEqualTo: startDate)
          .where('discountEndDate', isGreaterThanOrEqualTo: now)
          .orderBy('discountEndDate')
          .orderBy('discountPrice', descending: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('products')
          .where('discountPrice', isGreaterThan: 0)
          .orderBy('discountPrice', descending: true)
          .snapshots();
    }
  }
}
