import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasDiscount = discountPrice != null && discountPrice! < price;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth;
        final double imageHeight = cardWidth > 250
            ? 150
            : cardWidth > 180
            ? 120
            : 100;
        final double iconSize = cardWidth > 250 ? 22 : 18;
        final double buttonSize = cardWidth > 250 ? 36 : 30;
        final double nameFont = cardWidth > 250 ? 15 : 13.5;
        final double descFont = cardWidth > 250 ? 13 : 11.5;
        final double priceFont = cardWidth > 250 ? 14 : 12.5;
        final double priceFontSmall = priceFont - 2;
        final double verticalPad = cardWidth > 250 ? 10 : 7;
        final double horizontalPad = cardWidth > 250 ? 12 : 8;

        return GestureDetector(
          onTap: onTap,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
            clipBehavior: Clip.hardEdge,
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image (responsive height)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      imageUrl,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: imageHeight,
                        color: theme.colorScheme.surfaceVariant,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 32),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPad,
                        verticalPad,
                        horizontalPad,
                        verticalPad,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Text(
                            name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: nameFont,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          // Product Description (truncated)
                          Text(
                            description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                              fontSize: descFont,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          // Spacer to push price/button to the bottom
                          const Spacer(),
                          // Price and Add to Cart Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Price section (left)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (hasDiscount) ...[
                                    Text(
                                      '\$${price.toStringAsFixed(2)}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.5),
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontSize: priceFontSmall,
                                          ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '\$${discountPrice!.toStringAsFixed(2)}',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: priceFont,
                                          ),
                                    ),
                                  ] else ...[
                                    Text(
                                      '\$${price.toStringAsFixed(2)}',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: priceFont,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                              // Add to Cart button (right)
                              if (onAddToCart != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6.0),
                                  child: IconButton(
                                    onPressed: onAddToCart,
                                    icon: Icon(
                                      Icons.add_shopping_cart,
                                      size: iconSize,
                                    ),
                                    color: Colors.white,
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      minimumSize: Size(buttonSize, buttonSize),
                                      padding: EdgeInsets.zero,
                                    ),
                                    tooltip: 'Add to Cart',
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
