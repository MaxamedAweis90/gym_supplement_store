import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_supplement_store/widgets/product_card.dart';

class HotProductsScreen extends StatefulWidget {
  const HotProductsScreen({super.key});

  @override
  State<HotProductsScreen> createState() => _HotProductsScreenState();
}

class _HotProductsScreenState extends State<HotProductsScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadHotProducts();
  }

  Future<void> _loadHotProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('isHot', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _products = querySnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        _filteredProducts = List.from(_products);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch =
            product['name'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            product['category'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        final matchesCategory =
            _selectedCategory == 'All' ||
            product['category'] == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  List<String> get _categories {
    final categories = _products
        .map((p) => p['category'] as String)
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '🔥 Hot Products',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
            onPressed: _loadHotProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilter(context),

          // Products Grid
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : _filteredProducts.isEmpty
                ? _buildEmptyState(context)
                : _buildProductsGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              _searchQuery = value;
              _filterProducts();
            },
            decoration: InputDecoration(
              hintText: 'Search hot products...',
              prefixIcon: Icon(
                Icons.search,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Category Filter
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _filterProducts();
                      });
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text('No Hot Products Found', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(
            'Try adjusting your search or filters',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadHotProducts,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(context, product);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final theme = Theme.of(context);
    final double price = (product['price'] as num?)?.toDouble() ?? 0.0;
    final int? discount = product['discount'] as int?;
    final double? discountPrice = (discount != null)
        ? (price * (1 - discount / 100))
        : null;

    return Stack(
      children: [
        ProductCard(
          imageUrl: product['imageUrl'] ?? product['image'] ?? '',
          name: product['name'] ?? 'Unnamed Product',
          description: product['category'] ?? 'Uncategorized',
          price: price,
          discountPrice: discountPrice,
          onAddToCart: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product['name']} added to cart!')),
            );
          },
        ),
        // HOT badge
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }
}
