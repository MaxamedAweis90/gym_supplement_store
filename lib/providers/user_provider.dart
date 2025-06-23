import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User data cache
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get avatarUrl => _userData?['avatarUrl'];
  String? get username => _userData?['username'];
  String? get email => _userData?['email'];

  // --- FAVORITES LOGIC ---
  List<String> get favoriteProductIds =>
      (_userData?['favorites'] as List<dynamic>?)?.cast<String>() ?? [];

  bool isFavorite(String productId) => favoriteProductIds.contains(productId);

  Future<void> addFavorite(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'favorites': FieldValue.arrayUnion([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _userData ??= {};
      _userData!['favorites'] = favoriteProductIds..add(productId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'favorites': FieldValue.arrayRemove([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _userData ??= {};
      _userData!['favorites'] = favoriteProductIds..remove(productId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String productId) async {
    if (isFavorite(productId)) {
      await removeFavorite(productId);
    } else {
      await addFavorite(productId);
    }
  }

  // Initialize user data
  Future<void> initializeUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Check if we already have data for this user
    if (_userData != null && _userData!['uid'] == user.uid) {
      return; // Already loaded
    }

    await _loadUserData();
  }

  // Load user data from Firebase
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        _userData = {'uid': user.uid, ...doc.data()!};
      } else {
        // Create user document if it doesn't exist
        _userData = {
          'uid': user.uid,
          'username': user.displayName ?? 'User',
          'email': user.email,
          'avatarUrl': null,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _firestore.collection('users').doc(user.uid).set(_userData!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update avatar URL
  Future<void> updateAvatarUrl(String? avatarUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'avatarUrl': avatarUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local cache
      if (_userData != null) {
        _userData!['avatarUrl'] = avatarUrl;
        _userData!['updatedAt'] = FieldValue.serverTimestamp();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local cache
      if (_userData != null) {
        _userData!.addAll(data);
        _userData!['updatedAt'] = FieldValue.serverTimestamp();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Refresh user data (force reload)
  Future<void> refreshUserData() async {
    _userData = null; // Clear cache
    await _loadUserData();
  }

  // Clear user data on logout
  void clearUserData() {
    _userData = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Helper method to update state
  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  // Listen to real-time updates (optional)
  void startListeningToUserData() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore.collection('users').doc(user.uid).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _userData = {'uid': user.uid, ...snapshot.data()!};
        notifyListeners();
      }
    });
  }
}
