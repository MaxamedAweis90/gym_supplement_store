import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_supplement_store/pages/screens/hot_products_screen.dart';
import 'package:gym_supplement_store/pages/screens/latest_products_screen.dart';
import 'package:gym_supplement_store/widgets/product_card.dart';

class HomeTap extends StatefulWidget {
  const HomeTap({super.key});

  @override
  State<HomeTap> createState() => _HomeTapState();
}

class _HomeTapState extends State<HomeTap> {
  String _greeting = '';
  String _userName = '';
  List<Map<String, dynamic>> _hotProducts = [];
  List<Map<String, dynamic>> _latestProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setGreeting();
    _getUserName();
    _loadProducts();
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

  void _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      // Load hot products
      final hotQuery = await FirebaseFirestore.instance
          .collection('products')
          .where('isHot', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(4)
          .get();

      // Load latest products
      final latestQuery = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .limit(4)
          .get();

      setState(() {
        _hotProducts = hotQuery.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();

        _latestProducts = latestQuery.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoading = false;
      });

      // Show a user-friendly message and load dummy data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Unable to load products. Showing sample data.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Fallback to dummy data if Firebase fails
      _loadDummyData();
    }
  }

  void _loadDummyData() {
    setState(() {
      _hotProducts = [
        {
          'name': 'Whey Protein Isolate',
          'category': 'Protein Supplements',
          'price': 49.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1594736797933-d0401ba2fe65?w=400&h=300&fit=crop',
          'discount': 15,
        },
        {
          'name': 'Creatine Monohydrate',
          'category': 'Performance',
          'price': 24.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=400&h=300&fit=crop',
          'discount': 10,
        },
        {
          'name': 'BCAA Amino Acids',
          'category': 'Recovery',
          'price': 34.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
          'discount': 20,
        },
        {
          'name': 'Pre-Workout Energy',
          'category': 'Energy',
          'price': 39.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
          'discount': 12,
        },
      ];

      _latestProducts = [
        {
          'name': 'Omega-3 Fish Oil',
          'category': 'Vitamins',
          'price': 29.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&h=300&fit=crop',
        },
        {
          'name': 'Vitamin D3',
          'category': 'Vitamins',
          'price': 19.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=300&fit=crop',
        },
        {
          'name': 'Zinc Supplement',
          'category': 'Minerals',
          'price': 14.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
        },
        {
          'name': 'Magnesium Complex',
          'category': 'Minerals',
          'price': 22.99,
          'imageUrl':
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Greeting and Notification
              _buildHeader(context),

              // Promotion Banner
              _buildPromotionBanner(context),

              // Hot Products Section
              _buildHotProductsSection(context),

              // Latest Products Section
              _buildLatestProductsSection(context),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
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
                  _userName,
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
                // TODO: Navigate to notifications
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications coming soon!')),
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
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
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
                  '50% OFF\nProtein Powder',
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
                // TODO: Navigate to promotion products
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Promotion products coming soon!'),
                  ),
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

  Widget _buildHotProductsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🔥 Hot Products',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HotProductsScreen(),
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
        _isLoading
            ? SizedBox(
                height: 280,
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
            : _hotProducts.isEmpty
            ? SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_fire_department_outlined,
                        size: 50,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Hot Products Yet',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _hotProducts.length,
                  itemBuilder: (context, index) {
                    final product = _hotProducts[index];
                    final double price =
                        (product['price'] as num?)?.toDouble() ?? 0.0;
                    final int? discount = product['discount'] as int?;
                    final double? discountPrice = (discount != null)
                        ? (price * (1 - discount / 100))
                        : null;
                    return Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 16),
                      child: Stack(
                        children: [
                          ProductCard(
                            imageUrl: product['imageUrl'] ?? '',
                            name: product['name'] ?? '',
                            description: product['category'] ?? '',
                            price: price,
                            discountPrice: discountPrice,
                            onAddToCart: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product['name']} added to cart!',
                                  ),
                                ),
                              );
                            },
                          ),
                          // HOT badge
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'HOT',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Discount badge
                          if (discount != null)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '-$discount%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildLatestProductsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🆕 Latest Products',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LatestProductsScreen(),
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
        _isLoading
            ? SizedBox(
                height: 280,
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
            : _latestProducts.isEmpty
            ? SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.new_releases_outlined,
                        size: 50,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Latest Products Yet',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _latestProducts.length,
                  itemBuilder: (context, index) {
                    final product = _latestProducts[index];
                    final double price =
                        (product['price'] as num?)?.toDouble() ?? 0.0;
                    final int? discount = product['discount'] as int?;
                    final double? discountPrice = (discount != null)
                        ? (price * (1 - discount / 100))
                        : null;
                    return Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 16),
                      child: Stack(
                        children: [
                          ProductCard(
                            imageUrl: product['imageUrl'] ?? '',
                            name: product['name'] ?? '',
                            description: product['category'] ?? '',
                            price: price,
                            discountPrice: discountPrice,
                            onAddToCart: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product['name']} added to cart!',
                                  ),
                                ),
                              );
                            },
                          ),
                          // NEW badge
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'NEW',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Discount badge
                          if (discount != null)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '-$discount%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
