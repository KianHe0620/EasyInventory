// lib/controllers/supplier.controller.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/supplier.model.dart';

class SupplierController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // backing data (kept in-memory, synced from Firestore)
  final List<Supplier> _suppliers = [];

  // view / filtered list used by UI
  List<Supplier> filteredSuppliers = [];

  // selection state
  bool isSelectionMode = false;
  final Set<String> selectedSuppliers = {};

  // Firestore subscription
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  SupplierController() {
    // keep filtered view updated when search text changes
    searchController.addListener(_onSearchChanged);
    // start listening if user already signed in
    _watchAuthAndInit();
  }

  // If auth state changes, start/stop listening to the user's suppliers collection
  void _watchAuthAndInit() {
    // react to auth state changes
    _auth.authStateChanges().listen((user) {
      _sub?.cancel();
      _suppliers.clear();
      filteredSuppliers = [];
      if (user != null) {
        _startListening(user.uid);
      } else {
        // not signed in: remain empty
        notifyListeners();
      }
    });

    // if already signed in (app start)
    final u = _auth.currentUser;
    if (u != null) _startListening(u.uid);
  }

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('suppliers');

  void _startListening(String uid) {
    _sub = _col(uid).orderBy('name').snapshots().listen((snap) {
      _suppliers.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        // ensure id
        data['id'] = (data['id'] as String?)?.isNotEmpty == true ? data['id'] : doc.id;
        try {
          _suppliers.add(Supplier.fromMap(data));
        } catch (_) {
          // Defensive: if mapping fails, create a minimal supplier
          _suppliers.add(Supplier(id: doc.id, name: data['name']?.toString() ?? 'Unnamed'));
        }
      }
      // apply current search filter
      _applyFilter(searchController.text);
      notifyListeners();
    }, onError: (err) {
      // optionally log in debug
      if (kDebugMode) print('SupplierController snapshot error: $err');
    });
  }

  // ---------------------------
  // SEARCHING / FILTERING
  // ---------------------------
  void _onSearchChanged() {
    _applyFilter(searchController.text);
    notifyListeners();
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filteredSuppliers = List.from(_suppliers);
    } else {
      filteredSuppliers =
          _suppliers.where((s) => s.name.toLowerCase().contains(q)).toList();
    }
  }

  void filterSuppliers(String query) {
    searchController.text = query;
    // listener will call _applyFilter and notify
  }

  void clearSearch() {
    searchController.clear();
    // listener will update
  }

  // ---------------------------
  // SELECTION MODE
  // ---------------------------
  void toggleSelectionMode() {
    isSelectionMode = !isSelectionMode;
    if (!isSelectionMode) selectedSuppliers.clear();
    notifyListeners();
  }

  void toggleSelection(String supplierId) {
    if (selectedSuppliers.contains(supplierId)) {
      selectedSuppliers.remove(supplierId);
    } else {
      selectedSuppliers.add(supplierId);
    }
    notifyListeners();
  }

  bool isSelected(String supplierId) => selectedSuppliers.contains(supplierId);

  // ---------------------------
  // CRUD (uses Firestore)
  // ---------------------------
  Future<void> addSupplier(Supplier s) async {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Not signed in');
    final col = _col(u.uid);
    final id = s.id.isNotEmpty ? s.id : col.doc().id;
    final toSave = s.copyWith(id: id).toMap();
    await col.doc(id).set(toSave);
    // listener will pick up changes and update lists
  }

  Future<void> updateSupplier(String id, Supplier updated) async {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Not signed in');
    await _col(u.uid).doc(id).set(updated.copyWith(id: id).toMap());
    // listener will update
  }

  Future<void> removeSelectedSuppliers() async {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Not signed in');
    if (selectedSuppliers.isEmpty) return;
    final batch = _firestore.batch();
    final col = _col(u.uid);
    for (final id in selectedSuppliers) {
      batch.delete(col.doc(id));
    }
    await batch.commit();
    selectedSuppliers.clear();
    isSelectionMode = false;
    // listener will update lists
  }

  Future<void> deleteSupplier(String id) async {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Not signed in');
    await _col(u.uid).doc(id).delete();
    // listener will update
  }

  Supplier? getSupplierById(String id) {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // expose a snapshot of all suppliers (read-only)
  List<Supplier> get allSuppliers => List.unmodifiable(_suppliers);

  // ---------------------------
  // cleanup
  // ---------------------------
  @override
  void dispose() {
    _sub?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}
