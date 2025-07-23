import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../providers/user_provider.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/product_detail.dart';

class FavoriteTap extends StatelessWidget {
  const FavoriteTap({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final favoriteIds = userProvider.favoriteProductIds;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: favoriteIds.isEmpty
          ? _buildEmptyState(theme)
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where(
                    FieldPath.documentId,
                    whereIn: favoriteIds.isEmpty ? ['dummy'] : favoriteIds,
                  )
                  .snapshots(),
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
                    child: Text(
                      'Error loading favorites',
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }
                final products = snapshot.data?.docs ?? [];
                if (products.isEmpty) {
                  return _buildEmptyState(theme);
                }
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2;
                      double width = constraints.maxWidth;
                      if (width > 900) {
                        crossAxisCount = 4;
                      } else if (width > 600) {
                        crossAxisCount = 3;
                      }
                      return GridView.builder(
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
                            isFavorite: userProvider.isFavorite(productId),
                            onFavoriteToggle: () =>
                                userProvider.toggleFavorite(productId),
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
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.15),
                  theme.colorScheme.secondary.withOpacity(0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.favorite_border,
              size: 64,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Favorites Yet',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Products you mark as favorite will appear here.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
