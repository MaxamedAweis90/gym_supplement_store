import 'package:cloud_firestore/cloud_firestore.dart';

class SeedProductsService {
  static final List<Map<String, dynamic>> _initialProducts = [
    {
      'name': 'Whey Protein Isolate',
      'description':
          'High-quality whey protein isolate for muscle building and recovery. 25g protein per serving.',
      'price': 49.99,
      'category': 'Protein Supplements',
      'imageUrl':
          'https://images.unsplash.com/photo-1594736797933-d0401ba2fe65?w=400&h=300&fit=crop',
      'isHot': true,
      'discount': 15,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Creatine Monohydrate',
      'description':
          'Pure creatine monohydrate for increased strength and power output during workouts.',
      'price': 24.99,
      'category': 'Performance',
      'imageUrl':
          'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=400&h=300&fit=crop',
      'isHot': true,
      'discount': 10,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'BCAA Amino Acids',
      'description':
          'Branched-chain amino acids for muscle recovery and reducing muscle soreness.',
      'price': 34.99,
      'category': 'Recovery',
      'imageUrl':
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
      'isHot': true,
      'discount': 20,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Pre-Workout Energy',
      'description':
          'High-energy pre-workout formula with caffeine and beta-alanine for maximum performance.',
      'price': 39.99,
      'category': 'Energy',
      'imageUrl':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
      'isHot': true,
      'discount': 12,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Omega-3 Fish Oil',
      'description':
          'Premium fish oil supplement rich in EPA and DHA for heart and brain health.',
      'price': 29.99,
      'category': 'Vitamins',
      'imageUrl':
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&h=300&fit=crop',
      'isHot': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Vitamin D3',
      'description':
          'High-potency vitamin D3 supplement for bone health and immune support.',
      'price': 19.99,
      'category': 'Vitamins',
      'imageUrl':
          'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=300&fit=crop',
      'isHot': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Zinc Supplement',
      'description':
          'Essential zinc supplement for immune function and protein synthesis.',
      'price': 14.99,
      'category': 'Minerals',
      'imageUrl':
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
      'isHot': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Magnesium Complex',
      'description':
          'Magnesium supplement for muscle relaxation and better sleep quality.',
      'price': 22.99,
      'category': 'Minerals',
      'imageUrl':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
      'isHot': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Casein Protein',
      'description':
          'Slow-digesting casein protein for overnight muscle recovery and growth.',
      'price': 44.99,
      'category': 'Protein Supplements',
      'imageUrl':
          'https://images.unsplash.com/photo-1594736797933-d0401ba2fe65?w=400&h=300&fit=crop',
      'isHot': false,
      'discount': 8,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Glutamine Powder',
      'description':
          'L-glutamine supplement for gut health and muscle recovery.',
      'price': 18.99,
      'category': 'Recovery',
      'imageUrl':
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
      'isHot': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  static Future<void> seedProducts() async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final product in _initialProducts) {
        final docRef = FirebaseFirestore.instance.collection('products').doc();
        batch.set(docRef, product);
      }

      await batch.commit();
      print('Products seeded successfully!');
    } catch (e) {
      print('Error seeding products: $e');
    }
  }

  static Future<void> clearProducts() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Products cleared successfully!');
    } catch (e) {
      print('Error clearing products: $e');
    }
  }
}
