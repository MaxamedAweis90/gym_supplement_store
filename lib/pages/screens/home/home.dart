import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_supplement_store/widgets/shimmer_product_card.dart';
import 'package:provider/provider.dart';
import 'package:gym_supplement_store/providers/user_provider.dart';
import 'package:gym_supplement_store/widgets/product_card.dart';
import 'package:gym_supplement_store/pages/screens/home/latest_products_screen.dart';
import 'package:gym_supplement_store/pages/screens/home/deals_screen.dart';
import 'package:gym_supplement_store/widgets/product_detail.dart';
import 'package:gym_supplement_store/pages/screens/home/notifications.dart';

class HomeTap extends StatefulWidget {
  const HomeTap({super.key});

  @override
  State<HomeTap> createState() => _HomeTapState();
}

class _HomeTapState extends State<HomeTap> {
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    _setGreeting();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      setState(() {
        _greeting = 'Good Morning';
      });
    } else if (hour < 17) {
      setState(() {
        _greeting = 'Good Afternoon';
      });
    } else if (hour < 21) {
      setState(() {
        _greeting = 'Good Evening';
      });
    } else {
      setState(() {
        _greeting = 'Good Night';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Greeting and Notification
                _buildHeader(context),

                // Promotion Banner
                _buildPromotionBanner(context),

                const SizedBox(height: 24),

                // Latest Products Section
                _buildLatestProductsSection(context),

                const SizedBox(height: 0),

                // Deals Section
                _buildDealsSection(context),

                const SizedBox(height: 0),

                // All Products Section
                _buildAllProductsSection(context),

                const SizedBox(height: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final avatarUrl = userProvider.avatarUrl;

    return Container(
      width: double.infinity, // Ensures Row gets a bounded width
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Profile image with border and overlay border
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer overlay border
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.secondary.withOpacity(0.5),
                    width: 4,
                  ),
                ),
              ),
              // Inner border
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userProvider.username ?? 'Username...',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => NotificationsScreen()),
                );
              },
              icon: Stack(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionBanner(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'SPECIAL OFFER',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Up to 50% OFF\nPremium Supplements',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Limited time offer\nGet your gains now!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DealsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Shop Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestProductsSection(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Products',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LatestProductsScreen(),
                    ),
                  );
                },
                child: Text(
                  'View More',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .orderBy('createdAt', descending: true)
                .limit(6)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 4,
                  itemBuilder: (_, __) => const ShimmerProductCard(),
                );
              }

              final products = snapshot.data?.docs ?? [];

              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No products available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product =
                      products[index].data() as Map<String, dynamic>;
                  final productId = products[index].id;
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    child: ProductCard(
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
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDealsSection(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Deals & Discounts',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DealsScreen()),
                  );
                },
                child: Text(
                  'View More',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('discountPrice', isGreaterThan: 0)
                .orderBy('discountPrice', descending: true)
                .limit(6)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 4,
                  itemBuilder: (_, __) => const ShimmerProductCard(),
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
                        size: 48,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No deals available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product =
                      products[index].data() as Map<String, dynamic>;
                  final productId = products[index].id;
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    child: ProductCard(
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
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllProductsSection(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'All Products',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => const ShimmerProductCard(),
              );
            }

            final allProducts = snapshot.data?.docs ?? [];

            // Shuffle products to show random ones
            final randomProducts = List.from(allProducts);
            randomProducts.shuffle();

            // Take only first 8 products
            final products = randomProducts.take(8).toList();

            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No products available',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Products will appear here once added by admin',
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
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
            );
          },
        ),
      ],
    );
  }
}
