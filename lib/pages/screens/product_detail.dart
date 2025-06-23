import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:gym_supplement_store/providers/user_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final productId = product['id'] ?? product['productId'] ?? '';
    final bool hasDiscount =
        product['discountPrice'] != null &&
        product['discountPrice'] < product['price'];
    final bgColor = const Color.fromARGB(255, 255, 255, 255);
    final containerColor = Colors.white;
    final containerBorder = Border.all(
      color: theme.colorScheme.outline.withOpacity(0.08),
      width: 1.5,
    );
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              userProvider.isFavorite(productId)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: userProvider.isFavorite(productId)
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            onPressed: () => userProvider.toggleFavorite(productId),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                final containerWidth = screenWidth * 0.88;
                final containerHeight = containerWidth * 0.57;
                return Center(
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(20),
                      border: containerBorder,
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.network(
                        product['imageUrl'] ?? '',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              product['name'] ?? '',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  (product['rating']?.toString() ?? '4.5'),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  ' (15 Review)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hasDiscount
                  ? '\$${product['discountPrice'].toStringAsFixed(2)}'
                  : '\$${product['price'].toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            if (hasDiscount)
              Text(
                '\$${product['price'].toStringAsFixed(2)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  decoration: TextDecoration.lineThrough,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 18),
            Text(
              'Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product['description'] ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Color:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildColorCircle(Colors.black),
                const SizedBox(width: 8),
                _buildColorCircle(Colors.amber[100]!),
                const SizedBox(width: 8),
                _buildColorCircle(Colors.grey[400]!),
                const SizedBox(width: 8),
                _buildColorCircle(Colors.orange[100]!),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Size:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                'CHOOSE SIZE',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 28),
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
                onPressed: () {},
                child: const Text(
                  'Buy Now',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            if (product['supplementType'] != null &&
                product['supplementType'].toString().isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                'Supplement Type',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product['supplementType'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
            if (product['ingredients'] != null &&
                product['ingredients'].toString().isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                'Ingredients',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product['ingredients'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
            if (product['servingSize'] != null &&
                product['servingSize'].toString().isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                'Serving Size',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product['servingSize'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
            if (product['flavors'] != null &&
                product['flavors'].toString().isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                'Flavors',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product['flavors'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
            if (product['usage'] != null &&
                product['usage'].toString().isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                'Usage',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product['usage'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
            if (product['warnings'] != null &&
                product['warnings'].toString().isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                'Warnings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product['warnings'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
            if (product['nutritionFacts'] != null &&
                product['nutritionFacts'].toString().isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                'Nutrition Facts',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product['nutritionFacts'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
    );
  }
}
