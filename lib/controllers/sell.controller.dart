import 'package:flutter/foundation.dart';
import '../models/item.model.dart';
import '../models/sell.model.dart';
import 'item.controller.dart';

class SellController extends ChangeNotifier {
  final ItemController itemController;

  /// Map of itemId → quantity to sell
  final Map<String, int> saleQuantities = {};

  SellController({required this.itemController});

  /// Initialize saleQuantities to zero (or clear)
  void reset() {
    saleQuantities.clear();
    notifyListeners();
  }

  /// Set how many units of `item` will be sold
  void setQuantity(String itemId, int qty) {
    if (qty < 0) qty = 0;
    saleQuantities[itemId] = qty;
    notifyListeners();
  }

  /// Get the quantity set, default to 0
  int getQuantity(String itemId) {
    return saleQuantities[itemId] ?? 0;
  }

  /// Compute total for this sale
  double get totalAmount {
    double sum = 0.0;
    saleQuantities.forEach((itemId, qty) {
      final item = itemController.items.firstWhere(
        (it) => it.id == itemId,
        orElse: () => throw Exception("Item $itemId not found"),
      );
      sum += item.sellingPrice * qty;
    });
    return sum;
  }

  /// Validate that all requested quantities are <= available stock
  /// Returns null if OK, otherwise returns error message
  String? validate() {
    for (var entry in saleQuantities.entries) {
      final itemId = entry.key;
      final qty = entry.value;

      if (qty <= 0) continue;

      final index = itemController.items.indexWhere((it) => it.id == itemId);
      if (index == -1) {
        return "Item $itemId not found";
      }
      final item = itemController.items[index];

      if (item == null) {
        return "Item $itemId not found";
      }
      
      if (qty > item.quantity) {
        return "Cannot sell $qty of ${item.name}, only ${item.quantity} in stock.";
      }
    }
    return null;
  }

  /// Execute the sale: subtract from item stocks, return a SaleTransaction
  /// Throws if invalid
  Sell commitSale() {
    final error = validate();
    if (error != null) {
      throw Exception(error);
    }

    final Map<String, int> sold = {};
    saleQuantities.forEach((itemId, qty) {
      if (qty > 0) {
        sold[itemId] = qty;
        final idx = itemController.items.indexWhere((it) => it.id == itemId);
        final it = itemController.items[idx];
        final updated = it.copyWith(quantity: it.quantity - qty);
        itemController.updateItem(idx, updated);
      }
    });

    final sale = Sell(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      itemQuantities: sold,
      totalAmount: totalAmount,
    );

    // After commit, reset saleQuantities
    reset();
    return sale;
  }
}
