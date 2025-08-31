import 'package:flutter/material.dart';

class SupplierController {
  final TextEditingController searchController = TextEditingController();

  final List<String> suppliers = [
    "Apple Supplier",
    "Banana Supplier",
    "Cat Food Supplier",
    "Dog Toy Supplier",
    "Orange Supplier"
  ];

  List<String> filteredSuppliers = [];

  SupplierController() {
    filteredSuppliers = suppliers;
  }

  // 清空搜索
  void clearSearch() {
    searchController.clear();
    filteredSuppliers = suppliers;
  }

  // 过滤
  void filterSuppliers(String query) {
    if (query.isEmpty) {
      filteredSuppliers = suppliers;
    } else {
      filteredSuppliers = suppliers
          .where((s) => s.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}
