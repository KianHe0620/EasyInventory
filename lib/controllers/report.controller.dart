import 'package:flutter/foundation.dart';
import '../models/report.model.dart';
import 'item.controller.dart';
import 'sell.controller.dart';

class ReportController extends ChangeNotifier {
  final ItemController itemController;
  final SellController sellController;

  ReportController({
    required this.itemController,
    required this.sellController,
  });

  /// Generate Low Stock Report
  LowStockReport generateLowStockReport() {
    final now = DateTime.now();
    final items = itemController.items
        .where((it) => it.quantity <= it.minQuantity + 5) // threshold
        .map((it) {
          final avgOutflow = (it.minQuantity > 0) ? (it.quantity / it.minQuantity).toDouble() : 0;
          final estDays = avgOutflow > 0 ? (it.quantity / avgOutflow) : double.infinity;
          return {
            "name": it.name,
            "qty": it.quantity,
            "avgOutflow": avgOutflow,
            "estDays": estDays,
            "suggestion": "Restock ${(it.minQuantity * 3) - it.quantity} units for 30 days coverage",
          };
        }).toList();

    return LowStockReport(generatedOn: now, items: items);
  }

  /// Generate Weekly Sales Report
  WeeklySalesReport generateWeeklySalesReport(DateTime start, DateTime end) {
    final sales = sellController.salesHistory.where((s) =>
        s.date.isAfter(start.subtract(const Duration(days: 1))) &&
        s.date.isBefore(end.add(const Duration(days: 1))));

    double totalValue = 0;
    int totalSales = 0;
    final soldItems = <Map<String, dynamic>>[];

    for (var sale in sales) {
      totalValue += sale.totalAmount;
      totalSales += sale.itemQuantities.values.fold(0, (a, b) => a + b);

      sale.itemQuantities.forEach((itemId, qty) {
        final item = itemController.items.firstWhere((it) => it.id == itemId);
        soldItems.add({
          "name": item.name,
          "price": item.sellingPrice,
          "qty": qty,
        });
      });
    }

    return WeeklySalesReport(
      startDate: start,
      endDate: end,
      totalValue: totalValue,
      totalSales: totalSales,
      soldItems: soldItems,
    );
  }

  /// Generate Inventory Value Report
  InventoryValueReport generateInventoryValueReport() {
    final items = itemController.items;
    int totalItem = items.length;
    int totalQty = items.fold(0, (a, b) => a + b.quantity);
    double totalVal = items.fold(0, (a, b) => a + (b.quantity * b.sellingPrice));

    final overstock = items
        .where((it) => it.quantity > it.minQuantity + 100) // arbitrary overstock threshold
        .map((it) => {
              "name": it.name,
              "qty": it.quantity,
              "avgOutflow": 0, // TODO: use sales history to calculate
              "suggestion": "Consider bundling or removing",
            })
        .toList();

    return InventoryValueReport(
      totalItem: totalItem,
      totalQuantity: totalQty,
      totalValue: totalVal,
      overstockItems: overstock,
    );
  }
}
