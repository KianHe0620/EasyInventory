// lib/controllers/item.controller.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/item.model.dart';

class ItemController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // local cached list
  final List<Item> items = [];

  // Temp editing image paths (itemId -> local file path or empty string)
  // This stores user edits while they are in the edit page and have not pressed Save yet.
  final Map<String, String?> editingImagePaths = {};

  // Search / filter / sort state
  String searchQuery = "";
  Set<String> activeFields = {};
  String sortBy = "Name";
  bool ascending = true;

  // Selection state
  bool selectionMode = false;
  final Set<String> selectedIds = {};

  // user-scoped custom fields (in-memory)
  final Set<String> customFields = {};

  // fallback field string
  final String fallbackField = 'Uncategorized';

  // Firestore subscriptions
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _itemsSub;
  StreamSubscription<User?>? _authSub;

  ItemController() {
    // Start watching auth and then start item listener for signed-in user (or keep empty if not signed in)
    _watchAuthAndInit();
  }

  @override
  void dispose() {
    _itemsSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  // ------------- NEW: Editing image helpers -------------
  /// Set a temporary image path for editing. Use null or '' to indicate "no image".
  /// This does NOT persist to Firestore — call updateItem()/updateItemById() to persist.
  void setEditingImagePath(String itemId, String? path) {
    if (path == null || path.isEmpty) {
      editingImagePaths[itemId] = null;
    } else {
      editingImagePaths[itemId] = path;
    }
    if (kDebugMode) print('ItemController: setEditingImagePath for $itemId -> ${editingImagePaths[itemId]}');
    notifyListeners();
  }

  /// Clear the temporary editing image for the given item.
  void clearEditingImagePath(String itemId) {
    if (editingImagePaths.containsKey(itemId)) editingImagePaths.remove(itemId);
    if (kDebugMode) print('ItemController: clearEditingImagePath for $itemId');
    notifyListeners();
  }

  /// Returns the path that should be used for preview while editing:
  /// - if a temporary editing path exists => return it
  /// - else fallback to the saved Item.imagePath (may be empty)
  String? getEffectiveImagePath(String itemId) {
    if (editingImagePaths.containsKey(itemId)) {
      return editingImagePaths[itemId];
    }
    try {
      final it = items.firstWhere((i) => i.id == itemId);
      return it.imagePath.isNotEmpty ? it.imagePath : null;
    } catch (_) {
      return null;
    }
  }

  // ----------------- AUTH & INIT -----------------
  void _watchAuthAndInit() {
    // load fields if already signed in
    _loadCustomFieldsFromFirestoreIfSignedIn();

    // listen for auth changes
    _authSub = _auth.authStateChanges().listen((user) {
      if (kDebugMode) print('ItemController: auth changed -> ${user?.uid}');
      // stop current items subscription
      _itemsSub?.cancel();
      items.clear();
      editingImagePaths.clear();
      notifyListeners();

      // load per-user data (fields + items)
      if (user != null) {
        _startListeningItemsForUser(user.uid);
        _loadCustomFieldsFromFirestore();
      } else {
        // signed out
        customFields.clear();
        notifyListeners();
      }
    });

    // if already signed in, start listening
    final cur = _auth.currentUser;
    if (cur != null) {
      _startListeningItemsForUser(cur.uid);
      _loadCustomFieldsFromFirestore();
    }
  }

  // ----------------- ITEMS (per-user) -----------------
  void _startListeningItemsForUser(String uid) {
    final col = _userItemsCollection(uid);
    _itemsSub = col.snapshots().listen((snap) {
      items.clear();
      for (final doc in snap.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        // ensure document contains id field (backwards compatibility)
        if (!data.containsKey('id') || (data['id'] as String).isEmpty) {
          data['id'] = doc.id;
        }
        items.add(Item.fromMap(data));
      }
      if (kDebugMode) print('ItemController: loaded item ids => ${items.map((e) => e.id).toList()}');
      normalizeEmptyFields();
      sortItems(sortBy);
      notifyListeners();
    }, onError: (err) {
      if (kDebugMode) print('ItemController items snapshot error: $err');
    });
  }

  CollectionReference<Map<String, dynamic>> _userItemsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('items');
  }

  /// Adds item to Firestore. If item.id is empty, an auto-id is generated and persisted
  /// and the saved document will contain that id field (so doc.id === item.id).
  Future<void> addItem(Item item) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not signed in. Cannot add item to Firestore.');
    }
    final col = _userItemsCollection(user.uid);

    // prefer to use a docRef so we can get the assigned id and ensure item.id matches doc.id
    final docRef = item.id.isNotEmpty ? col.doc(item.id) : col.doc();
    final id = docRef.id;

    final toSave = item.copyWith(id: id);
    await docRef.set(toSave.toMap());
    if (kDebugMode) print('ItemController.addItem: saved item id=$id name=${toSave.name}');
    // snapshot listener will refresh local items list
  }

  /// Update item by index (keeps your signature). Ensures we use the persisted doc id,
  /// performs Firestore update (non-destructive) when possible.
  Future<void> updateItem(int index, Item updated) async {
    final user = _auth.currentUser;
    if (index < 0 || index >= items.length) return;
    if (user == null) {
      throw Exception('Not signed in. Cannot update item in Firestore.');
    }

    final id = items[index].id;
    if (id.isEmpty) {
      throw Exception('updateItem: item id is empty at index $index');
    }

    final docRef = _userItemsCollection(user.uid).doc(id);

    // Use update() to avoid unintentionally wiping fields; fallback to set() if update fails
    try {
      await docRef.update(updated.toMap());
      if (kDebugMode) print('ItemController.updateItem: updated doc $id (via update())');
    } on FirebaseException catch (e) {
      // If doc doesn't exist, set it
      if (e.code == 'not-found') {
        await docRef.set(updated.toMap());
        if (kDebugMode) print('ItemController.updateItem: doc not found, created doc $id (via set())');
      } else {
        if (kDebugMode) print('ItemController.updateItem: update failed for $id -> $e');
        rethrow; // rethrow so callers (like commitSale()) see the error if needed
      }
    } catch (e) {
      if (kDebugMode) print('ItemController.updateItem: unexpected error for $id -> $e');
      rethrow;
    }

    // Clear any temporary editing image after a successful save for this item
    if (editingImagePaths.containsKey(id)) {
      editingImagePaths.remove(id);
    }
    // snapshot listener will reflect the persisted change into local items
  }

  /// Convenience: update item by id (if you prefer passing id instead of index)
  Future<void> updateItemById(String id, Item updated) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not signed in. Cannot update item in Firestore.');
    if (id.isEmpty) throw Exception('updateItemById: id is empty');

    final docRef = _userItemsCollection(user.uid).doc(id);
    try {
      await docRef.update(updated.toMap());
      if (kDebugMode) print('ItemController.updateItemById: updated $id');
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        await docRef.set(updated.toMap());
        if (kDebugMode) print('ItemController.updateItemById: doc not found, created $id');
      } else {
        if (kDebugMode) print('ItemController.updateItemById: update failed for $id -> $e');
        rethrow;
      }
    }

    if (editingImagePaths.containsKey(id)) {
      editingImagePaths.remove(id);
    }
  }

  Future<void> deleteItem(Item item) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not signed in. Cannot delete item in Firestore.');
    }
    if (item.id.isEmpty) return;
    await _userItemsCollection(user.uid).doc(item.id).delete();
    if (kDebugMode) print('ItemController.deleteItem: deleted ${item.id}');
  }

  Future<void> deleteSelected() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not signed in. Cannot delete items in Firestore.');
    }
    final batch = _firestore.batch();
    final colRef = _userItemsCollection(user.uid);
    for (final id in selectedIds) {
      batch.delete(colRef.doc(id));
      // also clear temp editing image
      editingImagePaths.remove(id);
    }
    await batch.commit();
    selectedIds.clear();
    selectionMode = false;
  }

  /// Manual fetch (once), useful for migration/debug
  Future<void> loadOnceForCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final snap = await _userItemsCollection(user.uid).get();
    items.clear();
    for (final doc in snap.docs) {
      final data = doc.data();
      if (!data.containsKey('id') || (data['id'] as String).isEmpty) data['id'] = doc.id;
      items.add(Item.fromMap(data));
    }
    if (kDebugMode) print('ItemController.loadOnceForCurrentUser: loaded ids => ${items.map((e) => e.id).toList()}');
    normalizeEmptyFields();
    sortItems(sortBy);
    notifyListeners();
  }

  // ----------------- FIELDS (per-user/doc) -----------------
  DocumentReference<Map<String, dynamic>>? _fieldsDocRefForCurrentUser() {
    final u = _auth.currentUser;
    if (u == null) return null;
    return _firestore.collection('users').doc(u.uid).collection('settings').doc('fields');
  }

  Future<void> _loadCustomFieldsFromFirestoreIfSignedIn() async {
    final ref = _fieldsDocRefForCurrentUser();
    if (ref == null) return;
    await _loadCustomFieldsFromFirestore();
  }

  Future<void> _loadCustomFieldsFromFirestore() async {
    try {
      final ref = _fieldsDocRefForCurrentUser();
      if (ref == null) {
        if (kDebugMode) print('ItemController: no user signed in - skip loading fields.');
        return;
      }
      final doc = await ref.get();
      if (!doc.exists) {
        customFields.clear();
      } else {
        final data = doc.data()!;
        final list = (data['fields'] as List<dynamic>?)?.cast<String>() ?? [];
        customFields
          ..clear()
          ..addAll(list.where((s) => s != null).map((s) => s.trim()).where((s) => s.isNotEmpty));
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('ItemController: failed to load user fields: $e');
    }
  }

  Future<void> _saveCustomFieldsToFirestore() async {
    try {
      final ref = _fieldsDocRefForCurrentUser();
      if (ref == null) {
        if (kDebugMode) print('ItemController: not signed in - cannot save user fields.');
        return;
      }
      await ref.set({
        'fields': customFields.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('ItemController: failed to save user fields: $e');
    }
  }

  void addField(String name, {bool persist = true}) {
    final n = name.trim();
    if (n.isEmpty || n == fallbackField) return;
    customFields.add(n);
    notifyListeners();
    if (persist) _saveCustomFieldsToFirestore();
  }

  void removeField(String name, {bool persist = true}) {
    customFields.remove(name);
    notifyListeners();
    if (persist) _saveCustomFieldsToFirestore();
  }

  Set<String> getFields() {
    final derived = items.map((e) => e.field.isNotEmpty ? e.field : null).whereType<String>().toSet();
    return <String>{fallbackField}..addAll(customFields)..addAll(derived);
  }

  // ----------------- Helpers & UI API -----------------
  void normalizeEmptyFields() {
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      if (it.field.isEmpty) {
        items[i] = it.copyWith(field: fallbackField);
      }
    }
  }

  void setSearchQuery(String query) {
    searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void applyFilter(Set<String> fields, String sort, bool asc) {
    activeFields = fields;
    sortBy = sort;
    ascending = asc;
    sortItems(sortBy);
    notifyListeners();
  }

  void resetFilters() {
    activeFields.clear();
    sortBy = "Name";
    ascending = true;
    notifyListeners();
  }

  void toggleSortOrder() {
    ascending = !ascending;
    sortItems(sortBy);
    notifyListeners();
  }

  void sortItems(String criteria) {
    sortBy = criteria;
    int order(int cmp) => ascending ? cmp : -cmp;
    switch (criteria) {
      case "Quantity":
        items.sort((a, b) => order(a.quantity.compareTo(b.quantity)));
        break;
      case "Price":
        items.sort((a, b) => order(a.sellingPrice.compareTo(b.sellingPrice)));
        break;
      case "Field":
        items.sort((a, b) => order(a.field.compareTo(b.field)));
        break;
      case "Name":
      default:
        items.sort((a, b) => order(a.name.compareTo(b.name)));
        break;
    }
  }

  List<Item> getFilteredSortedItems() {
    final filtered = items.where((item) {
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchName = item.name.toLowerCase().contains(query);
        final matchBarcode = item.barcode.contains(query);
        if (!matchName && !matchBarcode) return false;
      }
      if (activeFields.isNotEmpty && !activeFields.contains(item.field)) return false;
      return true;
    }).toList();
    return filtered;
  }

  void toggleSelectionMode() {
    selectionMode = !selectionMode;
    if (!selectionMode) selectedIds.clear();
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) selectedIds.remove(id);
    else selectedIds.add(id);
    notifyListeners();
  }

  // ----------------- Migration helpers -----------------
  /// Push currently-cached (local) items to Firestore under the currently-signed-in user.
  /// Use this once after sign-in to migrate local seed data.
  Future<void> migrateLocalItemsToFirestoreForCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not signed in. Cannot migrate local items.');
    }
    final db = _firestore;
    final batch = db.batch();
    final col = _userItemsCollection(user.uid);
    for (final it in items) {
      final id = it.id.isNotEmpty ? it.id : col.doc().id;
      final ref = col.doc(id);
      batch.set(ref, it.copyWith(id: id).toMap());
    }
    await batch.commit();
    if (kDebugMode) print('ItemController.migrateLocalItemsToFirestoreForCurrentUser: migrated ${items.length} items');
  }
}
