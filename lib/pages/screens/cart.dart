import 'package:flutter/material.dart';

class CartTap extends StatelessWidget {
  const CartTap({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Cart Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text('Feature: Cart items will be displayed here.'),
        ],
      ),
    );
  }
}
