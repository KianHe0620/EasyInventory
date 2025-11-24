// lib/controllers/sell.controller.dart
import 'dart:async';
import 'package:easyinventory/controllers/item.controller.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sell.model.dart';
import '../models/item.model.dart';

class SellController extends ChangeNotifier {
  final ItemController itemController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, int> saleQuantities = {};
  final List<Sale> salesHistory = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _historySub;
  StreamSubscription<User?>? _authSub;

  // Use late final so we can initialize with onListen in constructor
  late final StreamController<List<Sale>> _salesStreamController;

  SellController({required this.itemController}) {
    // create a broadcast controller that emits current value to new listeners
    _salesStreamController = StreamController<List<Sale>>.broadcast(
      onListen: () {
        if (kDebugMode) print('salesStream onListen: emitting ${salesHistory.length} items');
        try {
          _salesStreamController.add(List<Sale>.from(salesHistory));
        } catch (e) {
          if (kDebugMode) print('salesStream onListen: add failed: $e');
        }
      },
    );

    // Start listening to auth changes so we start/stop Firestore listener properly
    _authSub = _auth.authStateChanges().listen((user) {
      if (kDebugMode) print('SellController auth change: user=${user?.uid}');
      if (user != null) {
        _startListeningToFirestore(user.uid);
        loadSalesOnce();
      } else {
        _historySub?.cancel();
        _historySub = null;
        salesHistory.clear();
        // ensure new listeners see the cleared list
        _salesStreamController.add(List<Sale>.from(salesHistory));
        notifyListeners();
      }
    });

    // if there's already a signed-in user at construction time, start listening
    final current = _auth.currentUser;
    if (current != null) {
      _startListeningToFirestore(current.uid);
      loadSalesOnce();
    }
  }

  @override
  void dispose() {
    _historySub?.cancel();
    _authSub?.cancel();
    _salesStreamController.close();
    super.dispose();
  }

  // -------------------------
  // Cart helpers
  // -------------------------
  int getQuantity(String itemId) => saleQuantities[itemId] ?? 0;

  void setQuantity(String itemId, int qty) {
    if (qty <= 0) {
      saleQuantities.remove(itemId);
    } else {
      saleQuantities[itemId] = qty;
    }
    notifyListeners();
  }

  void clearCart() {
    saleQuantities.clear();
    notifyListeners();
  }

  double get totalAmount {
    double sum = 0.0;
    for (final entry in saleQuantities.entries) {
      final itemId = entry.key;
      final qty = entry.value;
      try {
        final it = itemController.items.firstWhere((i) => i.id == itemId);
        sum += it.sellingPrice * qty;
      } catch (_) {
        // missing item -> skip (we rely on sale.totalAmount stored)
      }
    }
    return sum;
  }

  String? validate() {
    if (saleQuantities.isEmpty) return 'Cart is empty';
    for (final e in saleQuantities.entries) {
      final id = e.key;
      final qty = e.value;
      final it = itemController.items.firstWhere((i) => i.id == id, orElse: () => Item(
        id: '',
        name: 'Unknown',
        quantity: 0,
        minQuantity: 0,
        purchasePrice: 0,
        sellingPrice: 0,
        barcode: '',
        supplier: '',
        field: '',
        imagePath: '',
      ));
      if (it.id.isNotEmpty && qty > it.quantity) {
        return 'Insufficient stock for ${it.name}';
      }
    }
    return null;
  }

  // -------------------------
  // Commit sale (implemented)
  // -------------------------
  Future<Sale> commitSale({bool persistToFirestore = true}) async {
    final err = validate();
    if (err != null) throw Exception(err);

    final id = _firestore.collection('tmp').doc().id;
    final now = DateTime.now();
    final totals = totalAmount;

    // use item IDs as keys
    final Map<String, int> itemQuantities = Map<String, int>.from(saleQuantities);

    final sale = Sale(
      id: id,
      date: now,
      itemQuantities: itemQuantities,
      totalAmount: totals,
    );

    if (kDebugMode) print('commitSale: saving sale with keys: ${itemQuantities.keys.toList()}');

    try {
      // update each item (await updateItem)
      for (final entry in saleQuantities.entries) {
        final itemId = entry.key;
        final qty = entry.value;
        final idx = itemController.items.indexWhere((it) => it.id == itemId);
        if (idx != -1) {
          final it = itemController.items[idx];
          final updated = it.copyWith(quantity: (it.quantity - qty));
          try {
            // itemController.updateItem is async, await it
            await itemController.updateItem(idx, updated);
            if (kDebugMode) print('commitSale: updated item $itemId -> ${updated.quantity}');
          } catch (e) {
            if (kDebugMode) print('commitSale: failed to update item $itemId: $e');
            // continue; we still want to record the sale even if updating a single item fails
          }
        } else {
          if (kDebugMode) print('commitSale: item not found locally: $itemId');
        }
      }

      // local history + stream
      salesHistory.insert(0, sale);
      _salesStreamController.add(List<Sale>.from(salesHistory));
      notifyListeners();

      // persist to firestore (doesn't block clearing cart on error)
      if (persistToFirestore) {
        final user = _auth.currentUser;
        if (user != null) {
          try {
            final col = _firestore.collection('users').doc(user.uid).collection('sales');
            await col.doc(sale.id).set(sale.toMap());
            if (kDebugMode) print('commitSale: saved sale ${sale.id} to firestore for uid=${user.uid}');
          } catch (e) {
            if (kDebugMode) print('commitSale: failed to save sale to firestore: $e');
            // consider queuing unsynced sale if offline reliability needed
          }
        } else {
          if (kDebugMode) print('commitSale: no user signed in; skipped firestore save');
        }
      }

      return sale;
    } finally {
      // always clear cart and notify
      clearCart();
      if (kDebugMode) print('commitSale: cart cleared');
    }
  }

  // -------------------------
  // Migration helper
  // -------------------------
  Future<void> fixLegacySales({bool dryRun = true}) async {
    final user = _auth.currentUser;
    if (user == null) {
      if (kDebugMode) print('fixLegacySales: no user signed in');
      return;
    }
    final colRef = _firestore.collection('users').doc(user.uid).collection('sales');
    final snap = await colRef.get();
    for (final doc in snap.docs) {
      final data = doc.data();
      final Map<String, dynamic>? itemMap = (data['itemQuantities'] as Map<String, dynamic>?);
      if (itemMap == null) continue;
      final invalidKeys = <String>[];
      for (final k in itemMap.keys) {
        final exists = itemController.items.any((it) => it.id == k);
        if (!exists) invalidKeys.add(k);
      }
      if (invalidKeys.isNotEmpty) {
        if (kDebugMode) print('fixLegacySales: doc ${doc.id} invalid keys: $invalidKeys');
        if (!dryRun) {
          final updates = {
            'legacyItemQuantities': itemMap,
            'itemQuantities': <String, dynamic>{},
          };
          await colRef.doc(doc.id).update(updates);
          if (kDebugMode) print('fixLegacySales: updated doc ${doc.id}');
        }
      }
    }
    if (kDebugMode) print('fixLegacySales: done (dryRun=$dryRun)');
  }

  // -------------------------
  // Firestore listener
  // -------------------------
  void _startListeningToFirestore([String? uid]) {
    final userId = uid ?? _auth.currentUser?.uid;
    if (userId == null) {
      if (kDebugMode) print('_startListeningToFirestore: no uid');
      return;
    }
    _historySub?.cancel();
    try {
      final col = _firestore.collection('users').doc(userId).collection('sales').orderBy('date', descending: true);
      if (kDebugMode) print('_startListeningToFirestore: listening at users/$userId/sales');
      _historySub = col.snapshots().listen((snap) {
        if (kDebugMode) print('_startListeningToFirestore: got ${snap.docs.length} docs');
        salesHistory.clear();
        for (final doc in snap.docs) {
          final data = doc.data();
          try {
            salesHistory.add(Sale.fromMap(data));
          } catch (e) {
            if (kDebugMode) print('parse sale doc ${doc.id} failed: $e');
          }
        }
        _salesStreamController.add(List<Sale>.from(salesHistory));
        notifyListeners();
      }, onError: (err) {
        if (kDebugMode) print('SellController history listen error: $err');
        _salesStreamController.addError(err);
      });
    } catch (e) {
      if (kDebugMode) print('SellController firestore listen failed: $e');
      _salesStreamController.addError(e);
    }
  }

  Stream<List<Sale>> salesStream() => _salesStreamController.stream;

  Future<void> loadSalesOnce() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (kDebugMode) print('loadSalesOnce: no user signed in');
      return;
    }
    try {
      final snap = await _firestore.collection('users').doc(user.uid).collection('sales').orderBy('date', descending: true).get();
      salesHistory.clear();
      for (final doc in snap.docs) {
        try {
          salesHistory.add(Sale.fromMap(doc.data()));
        } catch (e) {
          if (kDebugMode) print('loadSalesOnce parse error doc ${doc.id}: $e');
        }
      }
      _salesStreamController.add(List<Sale>.from(salesHistory));
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('loadSalesOnce failed: $e');
      _salesStreamController.addError(e);
    }
  }

  // -------------------------
  // Helpers
  // -------------------------
  double getTodayProfit() {
    final today = DateTime.now();
    double profit = 0.0;
    for (final s in salesHistory) {
      if (s.date.year == today.year && s.date.month == today.month && s.date.day == today.day) {
        s.itemQuantities.forEach((itemId, qty) {
          try {
            final it = itemController.items.firstWhere((i) => i.id == itemId);
            profit += (it.sellingPrice - it.purchasePrice) * qty;
          } catch (_) {
            // item missing -> skip
          }
        });
      }
    }
    return profit;
  }
}
