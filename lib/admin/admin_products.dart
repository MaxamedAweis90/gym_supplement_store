import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_supplement_store/service/supabase_config.dart';
import 'dart:io';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();
      setState(() {
        _products = querySnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  Future<void> _deleteProduct(String productId, {String? imageUrl}) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await SupabaseConfig.deleteImage(imageUrl: imageUrl);
      }
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      setState(() {
        _products.removeWhere((product) => product['id'] == productId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error deleting product: If the image was already deleted, this is safe to ignore. $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Products Management',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.onSurface),
            onPressed: () => _showAddProductDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : _products.isEmpty
          ? _buildEmptyState(context)
          : _buildProductsList(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text('No Products Yet', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(
            'Start by adding your first product',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddProductDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add First Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: product['imageUrl'] != null && product['imageUrl'] != ''
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: theme.colorScheme.primary,
                          );
                        },
                      ),
                    )
                  : Icon(Icons.image, color: theme.colorScheme.primary),
            ),
            title: Text(
              product['name'] ?? 'Unnamed Product',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['description'] ?? 'No description',
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${product['price']?.toString() ?? '0.00'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Rating Display
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          '${product['rating']?.toString() ?? '4.5'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditProductDialog(context, product);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, product);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController();
    final ratingController = TextEditingController(text: '4.5');
    int? discount;
    String? selectedImageUrl;
    DateTime? discountStartDate;
    DateTime? discountEndDate;
    final supplementTypeController = TextEditingController();
    final ingredientsController = TextEditingController();
    final servingSizeController = TextEditingController();
    final flavorsController = TextEditingController();
    final usageController = TextEditingController();
    final warningsController = TextEditingController();
    final nutritionFactsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: Container(
            width: 400,
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add New Product',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Dispose controllers before closing
                          nameController.dispose();
                          descriptionController.dispose();
                          priceController.dispose();
                          categoryController.dispose();
                          ratingController.dispose();
                          supplementTypeController.dispose();
                          ingredientsController.dispose();
                          servingSizeController.dispose();
                          flavorsController.dispose();
                          usageController.dispose();
                          warningsController.dispose();
                          nutritionFactsController.dispose();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Product Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.shopping_bag),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: ratingController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Rating (0.0 - 5.0)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.star),
                            hintText: '4.5',
                          ),
                        ),
                        const SizedBox(height: 16),
                        AdminProductImagePicker(
                          initialImageUrl: selectedImageUrl,
                          onImageChanged: (url) {
                            setState(() => selectedImageUrl = url);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Discount % (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.discount),
                          ),
                          onChanged: (value) {
                            discount = int.tryParse(value);
                          },
                        ),
                        const SizedBox(height: 16),
                        // Discount Date Fields
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                controller: TextEditingController(
                                  text: discountStartDate != null
                                      ? '${discountStartDate!.day}/${discountStartDate!.month}/${discountStartDate!.year}'
                                      : 'Select Start Date',
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Discount Start Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      discountStartDate = date;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                controller: TextEditingController(
                                  text: discountEndDate != null
                                      ? '${discountEndDate!.day}/${discountEndDate!.month}/${discountEndDate!.year}'
                                      : 'Select End Date',
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Discount End Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().add(
                                      const Duration(days: 10),
                                    ),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      discountEndDate = date;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: supplementTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Supplement Type (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                            hintText: 'e.g. Protein, Pre-Workout, Multivitamin',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: ingredientsController,
                          decoration: const InputDecoration(
                            labelText: 'Ingredients (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.science),
                            hintText: 'e.g. Whey, Creatine, BCAAs',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: servingSizeController,
                          decoration: const InputDecoration(
                            labelText: 'Serving Size (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_drink),
                            hintText: 'e.g. 30g, 1 scoop',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: flavorsController,
                          decoration: const InputDecoration(
                            labelText: 'Flavors (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.icecream),
                            hintText: 'e.g. Chocolate, Vanilla',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: usageController,
                          decoration: const InputDecoration(
                            labelText: 'Usage (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.fitness_center),
                            hintText: 'e.g. Take 1 scoop post-workout',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: warningsController,
                          decoration: const InputDecoration(
                            labelText: 'Warnings (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.warning),
                            hintText: 'e.g. Not for children',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: nutritionFactsController,
                          decoration: const InputDecoration(
                            labelText: 'Nutrition Facts (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.fact_check),
                            hintText: 'e.g. Protein: 24g, Carbs: 3g',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Dispose controllers before closing
                          nameController.dispose();
                          descriptionController.dispose();
                          priceController.dispose();
                          categoryController.dispose();
                          ratingController.dispose();
                          supplementTypeController.dispose();
                          ingredientsController.dispose();
                          servingSizeController.dispose();
                          flavorsController.dispose();
                          usageController.dispose();
                          warningsController.dispose();
                          nutritionFactsController.dispose();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Product name is required'),
                              ),
                            );
                            return;
                          }
                          if (categoryController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Category is required'),
                              ),
                            );
                            return;
                          }
                          if (selectedImageUrl == null ||
                              selectedImageUrl?.isEmpty == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Product image is required'),
                              ),
                            );
                            return;
                          }

                          // Validate rating
                          final rating = double.tryParse(ratingController.text);
                          if (rating == null || rating < 0 || rating > 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Rating must be between 0.0 and 5.0',
                                ),
                              ),
                            );
                            return;
                          }

                          // Validate discount dates if discount is set
                          if (discount != null && discount! > 0) {
                            if (discountStartDate == null ||
                                discountEndDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select both start and end dates for discount',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (discountEndDate!.isBefore(discountStartDate!)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'End date must be after start date',
                                  ),
                                ),
                              );
                              return;
                            }
                          }

                          try {
                            final price =
                                double.tryParse(priceController.text) ?? 0.0;
                            double? discountPrice;

                            // Calculate discount price if discount is set
                            if (discount != null && discount! > 0) {
                              discountPrice = price * (1 - discount! / 100);
                            }

                            await FirebaseFirestore.instance
                                .collection('products')
                                .add({
                                  'name': nameController.text.trim(),
                                  'description': descriptionController.text
                                      .trim(),
                                  'price': price,
                                  'category': categoryController.text.trim(),
                                  'rating': rating,
                                  'imageUrl': selectedImageUrl,
                                  'discount': discount,
                                  'discountPrice': discountPrice,
                                  'discountStartDate': discountStartDate,
                                  'discountEndDate': discountEndDate,
                                  'supplementType': supplementTypeController
                                      .text
                                      .trim(),
                                  'ingredients': ingredientsController.text
                                      .trim(),
                                  'servingSize': servingSizeController.text
                                      .trim(),
                                  'flavors': flavorsController.text.trim(),
                                  'usage': usageController.text.trim(),
                                  'warnings': warningsController.text.trim(),
                                  'nutritionFacts': nutritionFactsController
                                      .text
                                      .trim(),
                                  'createdAt': FieldValue.serverTimestamp(),
                                });
                            // Dispose controllers before closing
                            nameController.dispose();
                            descriptionController.dispose();
                            priceController.dispose();
                            categoryController.dispose();
                            ratingController.dispose();
                            supplementTypeController.dispose();
                            ingredientsController.dispose();
                            servingSizeController.dispose();
                            flavorsController.dispose();
                            usageController.dispose();
                            warningsController.dispose();
                            nutritionFactsController.dispose();
                            Navigator.of(context).pop();
                            _loadProducts();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Product added successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error adding product: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Add Product'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProductDialog(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: product['name'] ?? '');
    final descriptionController = TextEditingController(
      text: product['description'] ?? '',
    );
    final priceController = TextEditingController(
      text: product['price']?.toString() ?? '',
    );
    final categoryController = TextEditingController(
      text: product['category'] ?? '',
    );
    final discountController = TextEditingController(
      text: product['discount']?.toString() ?? '',
    );
    final ratingController = TextEditingController(
      text: product['rating']?.toString() ?? '4.5',
    );
    int? discount = product['discount'];
    String? selectedImageUrl = product['imageUrl'];
    DateTime? discountStartDate = product['discountStartDate']?.toDate();
    DateTime? discountEndDate = product['discountEndDate']?.toDate();
    final supplementTypeController = TextEditingController(
      text: product['supplementType'] ?? '',
    );
    final ingredientsController = TextEditingController(
      text: product['ingredients'] ?? '',
    );
    final servingSizeController = TextEditingController(
      text: product['servingSize'] ?? '',
    );
    final flavorsController = TextEditingController(
      text: product['flavors'] ?? '',
    );
    final usageController = TextEditingController(text: product['usage'] ?? '');
    final warningsController = TextEditingController(
      text: product['warnings'] ?? '',
    );
    final nutritionFactsController = TextEditingController(
      text: product['nutritionFacts'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: Container(
            width: 400,
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Edit Product',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Dispose controllers before closing
                          nameController.dispose();
                          descriptionController.dispose();
                          priceController.dispose();
                          categoryController.dispose();
                          discountController.dispose();
                          ratingController.dispose();
                          supplementTypeController.dispose();
                          ingredientsController.dispose();
                          servingSizeController.dispose();
                          flavorsController.dispose();
                          usageController.dispose();
                          warningsController.dispose();
                          nutritionFactsController.dispose();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Product Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.shopping_bag),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: ratingController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Rating (0.0 - 5.0)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.star),
                            hintText: '4.5',
                          ),
                        ),
                        const SizedBox(height: 16),
                        AdminProductImagePicker(
                          initialImageUrl: selectedImageUrl,
                          onImageChanged: (url) {
                            setState(() => selectedImageUrl = url);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Discount % (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.discount),
                          ),
                          controller: discountController,
                          onChanged: (value) {
                            discount = int.tryParse(value);
                          },
                        ),
                        const SizedBox(height: 16),
                        // Discount Date Fields
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                controller: TextEditingController(
                                  text: discountStartDate != null
                                      ? '${discountStartDate!.day}/${discountStartDate!.month}/${discountStartDate!.year}'
                                      : 'Select Start Date',
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Discount Start Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        discountStartDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      discountStartDate = date;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                controller: TextEditingController(
                                  text: discountEndDate != null
                                      ? '${discountEndDate!.day}/${discountEndDate!.month}/${discountEndDate!.year}'
                                      : 'Select End Date',
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Discount End Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        discountEndDate ??
                                        DateTime.now().add(
                                          const Duration(days: 10),
                                        ),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      discountEndDate = date;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: supplementTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Supplement Type (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                            hintText: 'e.g. Protein, Pre-Workout, Multivitamin',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: ingredientsController,
                          decoration: const InputDecoration(
                            labelText: 'Ingredients (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.science),
                            hintText: 'e.g. Whey, Creatine, BCAAs',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: servingSizeController,
                          decoration: const InputDecoration(
                            labelText: 'Serving Size (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_drink),
                            hintText: 'e.g. 30g, 1 scoop',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: flavorsController,
                          decoration: const InputDecoration(
                            labelText: 'Flavors (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.icecream),
                            hintText: 'e.g. Chocolate, Vanilla',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: usageController,
                          decoration: const InputDecoration(
                            labelText: 'Usage (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.fitness_center),
                            hintText: 'e.g. Take 1 scoop post-workout',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: warningsController,
                          decoration: const InputDecoration(
                            labelText: 'Warnings (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.warning),
                            hintText: 'e.g. Not for children',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: nutritionFactsController,
                          decoration: const InputDecoration(
                            labelText: 'Nutrition Facts (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.fact_check),
                            hintText: 'e.g. Protein: 24g, Carbs: 3g',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Dispose controllers before closing
                          nameController.dispose();
                          descriptionController.dispose();
                          priceController.dispose();
                          categoryController.dispose();
                          discountController.dispose();
                          ratingController.dispose();
                          supplementTypeController.dispose();
                          ingredientsController.dispose();
                          servingSizeController.dispose();
                          flavorsController.dispose();
                          usageController.dispose();
                          warningsController.dispose();
                          nutritionFactsController.dispose();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Product name is required'),
                              ),
                            );
                            return;
                          }
                          if (categoryController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Category is required'),
                              ),
                            );
                            return;
                          }
                          if (selectedImageUrl == null ||
                              selectedImageUrl?.isEmpty == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Product image is required'),
                              ),
                            );
                            return;
                          }

                          // Validate rating
                          final rating = double.tryParse(ratingController.text);
                          if (rating == null || rating < 0 || rating > 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Rating must be between 0.0 and 5.0',
                                ),
                              ),
                            );
                            return;
                          }

                          // Validate discount dates if discount is set
                          if (discount != null && discount! > 0) {
                            if (discountStartDate == null ||
                                discountEndDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select both start and end dates for discount',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (discountEndDate!.isBefore(discountStartDate!)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'End date must be after start date',
                                  ),
                                ),
                              );
                              return;
                            }
                          }

                          try {
                            final price =
                                double.tryParse(priceController.text) ?? 0.0;
                            double? discountPrice;

                            // Calculate discount price if discount is set
                            if (discount != null && discount! > 0) {
                              discountPrice = price * (1 - discount! / 100);
                            }

                            await FirebaseFirestore.instance
                                .collection('products')
                                .doc(product['id'])
                                .update({
                                  'name': nameController.text.trim(),
                                  'description': descriptionController.text
                                      .trim(),
                                  'price': price,
                                  'category': categoryController.text.trim(),
                                  'rating': rating,
                                  'imageUrl': selectedImageUrl,
                                  'discount': discount,
                                  'discountPrice': discountPrice,
                                  'discountStartDate': discountStartDate,
                                  'discountEndDate': discountEndDate,
                                  'supplementType': supplementTypeController
                                      .text
                                      .trim(),
                                  'ingredients': ingredientsController.text
                                      .trim(),
                                  'servingSize': servingSizeController.text
                                      .trim(),
                                  'flavors': flavorsController.text.trim(),
                                  'usage': usageController.text.trim(),
                                  'warnings': warningsController.text.trim(),
                                  'nutritionFacts': nutritionFactsController
                                      .text
                                      .trim(),
                                  'updatedAt': FieldValue.serverTimestamp(),
                                });
                            // Dispose controllers before closing
                            nameController.dispose();
                            descriptionController.dispose();
                            priceController.dispose();
                            categoryController.dispose();
                            discountController.dispose();
                            ratingController.dispose();
                            supplementTypeController.dispose();
                            ingredientsController.dispose();
                            servingSizeController.dispose();
                            flavorsController.dispose();
                            usageController.dispose();
                            warningsController.dispose();
                            nutritionFactsController.dispose();
                            Navigator.of(context).pop();
                            _loadProducts();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Product updated successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error updating product: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Update Product'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Delete Product',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${product['name']}"?',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteProduct(
                        product['id'],
                        imageUrl: product['imageUrl'],
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable widget for picking/uploading/removing product images in admin dialogs
class AdminProductImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final void Function(String? imageUrl) onImageChanged;

  const AdminProductImagePicker({
    super.key,
    this.initialImageUrl,
    required this.onImageChanged,
  });

  @override
  State<AdminProductImagePicker> createState() =>
      _AdminProductImagePickerState();
}

class _AdminProductImagePickerState extends State<AdminProductImagePicker> {
  String? _imageUrl;
  File? _imageFile;
  bool _isUploading = false;
  String? _oldImageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
    _oldImageUrl = widget.initialImageUrl;
  }

  Future<void> _pickImage() async {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                await _handlePick(SupabaseConfig.pickImageFromGallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.of(context).pop();
                await _handlePick(SupabaseConfig.takePhotoWithCamera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePick(Future<File?> Function() pickFn) async {
    setState(() => _isUploading = true);
    final file = await pickFn();
    if (file != null) {
      final url = await SupabaseConfig.uploadImage(
        imageFile: file,
        bucketName: 'product-images',
      );
      if (url != null) {
        // Delete old image if it exists and is different
        if (_imageUrl != null && _imageUrl != url) {
          await SupabaseConfig.deleteImage(imageUrl: _imageUrl!);
        }
        setState(() {
          _imageFile = file;
          _imageUrl = url;
        });
        widget.onImageChanged(url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    setState(() => _isUploading = false);
  }

  void _removeImage() async {
    // Delete old image if it exists
    if (_imageUrl != null) {
      await SupabaseConfig.deleteImage(imageUrl: _imageUrl!);
    }
    setState(() {
      _imageFile = null;
      _imageUrl = null;
    });
    widget.onImageChanged(null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image removed'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 350,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : _imageUrl != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(_imageUrl!, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: _removeImage,
                    ),
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: _pickImage,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 48,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add image',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
