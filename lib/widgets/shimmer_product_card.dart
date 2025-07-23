import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 120, width: double.infinity, color: Colors.grey),
            const SizedBox(height: 12),
            Container(height: 16, width: 120, color: Colors.grey),
            const SizedBox(height: 8),
            Container(height: 14, width: 80, color: Colors.grey),
            const SizedBox(height: 12),
            Container(height: 14, width: 60, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
