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
                Text(
                  '\$${product['price']?.toString() ?? '0.00'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
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
    bool isHot = false;
    int? discount;
    String? selectedImageUrl;

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
                        onPressed: () => Navigator.of(context).pop(),
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
                        AdminProductImagePicker(
                          initialImageUrl: selectedImageUrl,
                          onImageChanged: (url) {
                            setState(() => selectedImageUrl = url);
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: isHot,
                              onChanged: (value) {
                                setState(() {
                                  isHot = value ?? false;
                                });
                              },
                            ),
                            const Text('Mark as Hot Product'),
                          ],
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
                        onPressed: () => Navigator.of(context).pop(),
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
                          try {
                            await FirebaseFirestore.instance
                                .collection('products')
                                .add({
                                  'name': nameController.text.trim(),
                                  'description': descriptionController.text
                                      .trim(),
                                  'price':
                                      double.tryParse(priceController.text) ??
                                      0.0,
                                  'category': categoryController.text.trim(),
                                  'imageUrl': selectedImageUrl,
                                  'isHot': isHot,
                                  'discount': discount,
                                  'createdAt': FieldValue.serverTimestamp(),
                                });
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
    bool isHot = product['isHot'] ?? false;
    int? discount = product['discount'];
    String? selectedImageUrl = product['imageUrl'];

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
                        onPressed: () => Navigator.of(context).pop(),
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
                        AdminProductImagePicker(
                          initialImageUrl: selectedImageUrl,
                          onImageChanged: (url) {
                            setState(() => selectedImageUrl = url);
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: isHot,
                              onChanged: (value) {
                                setState(() {
                                  isHot = value ?? false;
                                });
                              },
                            ),
                            const Text('Mark as Hot Product'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Discount % (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.discount),
                          ),
                          controller: TextEditingController(
                            text: discount?.toString() ?? '',
                          ),
                          onChanged: (value) {
                            discount = int.tryParse(value);
                          },
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
                        onPressed: () => Navigator.of(context).pop(),
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
                          try {
                            await FirebaseFirestore.instance
                                .collection('products')
                                .doc(product['id'])
                                .update({
                                  'name': nameController.text.trim(),
                                  'description': descriptionController.text
                                      .trim(),
                                  'price':
                                      double.tryParse(priceController.text) ??
                                      0.0,
                                  'category': categoryController.text.trim(),
                                  'imageUrl': selectedImageUrl,
                                  'isHot': isHot,
                                  'discount': discount,
                                  'updatedAt': FieldValue.serverTimestamp(),
                                });
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
                'Are you sure you want to delete \"${product['name']}\"?',
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
