import 'package:flutter/material.dart';

class SupplierController extends ChangeNotifier {
  /// Search controller for the search bar
  final TextEditingController searchController = TextEditingController();

  /// Full list of suppliers
  final List<String> _suppliers = [
    "Apple Supplier",
    "Banana Supplier",
    "Cat Food Supplier",
    "Dog Toy Supplier",
    "Orange Supplier"
  ];

  /// Filtered list of suppliers (for search)
  List<String> filteredSuppliers = [];

  /// Selection mode state
  bool isSelectionMode = false;

  /// Selected suppliers
  final Set<String> selectedSuppliers = {};

  SupplierController() {
    filteredSuppliers = List.from(_suppliers);
  }

  // -----------------------------
  // 🔍 SEARCHING
  // -----------------------------

  void filterSuppliers(String query) {
    if (query.isEmpty) {
      filteredSuppliers = List.from(_suppliers);
    } else {
      filteredSuppliers = _suppliers
          .where((s) => s.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    filteredSuppliers = List.from(_suppliers);
    notifyListeners();
  }

  // -----------------------------
  // ✅ SELECTION MODE
  // -----------------------------

  void toggleSelectionMode() {
    isSelectionMode = !isSelectionMode;
    if (!isSelectionMode) {
      selectedSuppliers.clear();
    }
    notifyListeners();
  }

  void toggleSelection(String supplier) {
    if (selectedSuppliers.contains(supplier)) {
      selectedSuppliers.remove(supplier);
    } else {
      selectedSuppliers.add(supplier);
    }
    notifyListeners();
  }

  bool isSelected(String supplier) {
    return selectedSuppliers.contains(supplier);
  }

  // -----------------------------
  // 🗑️ SUPPLIER MANAGEMENT
  // -----------------------------

  void removeSuppliers() {
    _suppliers.removeWhere((s) => selectedSuppliers.contains(s));
    filteredSuppliers.removeWhere((s) => selectedSuppliers.contains(s));
    selectedSuppliers.clear();
    isSelectionMode = false;
    notifyListeners();
  }

  // -----------------------------
  // 📦 SUPPLIER ITEMS (example)
  // -----------------------------

  final List<Map<String, String>> items = [
    {"name": "Cat Food", "imagePath": ""},
    {"name": "Cat Toy", "imagePath": ""},
    {"name": "Cat Bed", "imagePath": ""},
  ];
}
