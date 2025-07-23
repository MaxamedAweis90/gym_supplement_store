import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double? discountPrice;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.discountPrice,
    this.quantity = 1,
  });

  double get totalPrice => (discountPrice ?? price) * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.length;
  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal =>
      _items.values.fold(0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => items.isEmpty ? 0 : 30;
  double get total => subtotal + deliveryFee;

  void addToCart({
    required String id,
    required String name,
    required String imageUrl,
    required double price,
    double? discountPrice,
    int quantity = 1,
  }) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity += quantity;
    } else {
      _items[id] = CartItem(
        id: id,
        name: name,
        imageUrl: imageUrl,
        price: price,
        discountPrice: discountPrice,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity = quantity;
      if (_items[id]!.quantity <= 0) {
        _items.remove(id);
      }
      notifyListeners();
    }
  }

  void incrementQuantity(String id) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String id) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity--;
      if (_items[id]!.quantity <= 0) {
        _items.remove(id);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String id) => _items.containsKey(id);
  int getQuantity(String id) => _items[id]?.quantity ?? 0;
}
