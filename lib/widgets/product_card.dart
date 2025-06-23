import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double price;
  final double? discountPrice;
  final double? rating;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;
  final double cardWidth;
  final double imageContainerWidth;
  final double imageContainerHeight;
  final double imageWidth;
  final double imageHeight;

  /// [cardWidth], [imageContainerWidth], [imageContainerHeight], [imageWidth], and [imageHeight] are optional.
  /// You can use them to control the card and image sizes. Defaults are visually balanced.
  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.discountPrice,
    this.rating,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
    this.cardWidth = 120,
    this.imageContainerWidth = 220,
    this.imageContainerHeight = 140,
    this.imageWidth = 100,
    this.imageHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasDiscount = discountPrice != null && discountPrice! < price;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: imageContainerWidth,
                    height: imageContainerHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.network(
                        imageUrl,
                        width: imageWidth,
                        height: imageHeight,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported_outlined,
                          size: 32,
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                  if (onFavoriteToggle != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onFavoriteToggle,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (hasDiscount) ...[
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      decoration: TextDecoration.lineThrough,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '\$${discountPrice!.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ] else ...[
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      (rating?.toStringAsFixed(1) ?? '4.5'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
