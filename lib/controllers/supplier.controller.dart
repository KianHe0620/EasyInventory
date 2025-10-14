import 'package:flutter/material.dart';
import '../models/supplier.model.dart';

class SupplierController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  final List<Supplier> _suppliers = [
    Supplier(id: "1", name: "Apple Supplier"),
    Supplier(id: "2", name: "Banana Supplier"),
    Supplier(id: "3", name: "Cat Food Supplier"),
    Supplier(id: "4", name: "Dog Toy Supplier"),
    Supplier(id: "5", name: "Orange Supplier"),
  ];

  List<Supplier> filteredSuppliers = [];

  bool isSelectionMode = false;
  final Set<String> selectedSuppliers = {};

  SupplierController() {
    filteredSuppliers = List.from(_suppliers);
  }

  // 🔍 SEARCH
  void filterSuppliers(String query) {
    if (query.isEmpty) {
      filteredSuppliers = List.from(_suppliers);
    } else {
      filteredSuppliers = _suppliers
          .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    filteredSuppliers = List.from(_suppliers);
    notifyListeners();
  }

  // ✅ SELECTION
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

  // 🗑️ REMOVE
  void removeSuppliers() {
    _suppliers.removeWhere((s) => selectedSuppliers.contains(s.id));
    filteredSuppliers.removeWhere((s) => selectedSuppliers.contains(s.id));
    selectedSuppliers.clear();
    isSelectionMode = false;
    notifyListeners();
  }

  // ➕ ADD
  void addSupplier(Supplier supplier) {
    _suppliers.add(supplier);
    filterSuppliers(searchController.text);
    notifyListeners();
  }

  // ✏️ UPDATE
  void updateSupplier(String id, Supplier updated) {
    final index = _suppliers.indexWhere((s) => s.id == id);
    if (index != -1) {
      _suppliers[index] = updated;
      filterSuppliers(searchController.text);
      notifyListeners();
    }
  }

  Supplier? getSupplierById(String id) {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
