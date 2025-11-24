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
            "suggestion": "Restock ${(avgOutflow * 30) - it.quantity} units for 30 days coverage",
          };
        }).toList();

    return LowStockReport(generatedOn: now, items: items);
  }

  /// Generate Weekly Sales Report
  ///
  /// - safe when items have been deleted: falls back to 'Unknown item' and uses sale.totalAmount
  /// - aggregates sold items by item id (name/price used if item exists)
  WeeklySalesReport generateWeeklySalesReport(DateTime start, DateTime end) {
    // normalize the range to include the entire start and end days
    final DateTime startInclusive = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final DateTime endInclusive = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final sales = sellController.salesHistory.where((s) =>
        !s.date.isBefore(startInclusive) && !s.date.isAfter(endInclusive));

    double totalValue = 0.0;
    int totalItemsSold = 0;

    // aggregate map: itemId -> { name, price, qty }
    final Map<String, Map<String, dynamic>> aggregated = {};

    for (var sale in sales) {
      // Always trust stored totalAmount (useful if items were deleted later)
      totalValue += sale.totalAmount;

      // Sum quantities (sum of all quantities across itemQuantities)
      final saleQtySum = sale.itemQuantities.values.fold<int>(0, (a, b) => a + b);
      totalItemsSold += saleQtySum;

      // Aggregate per itemId
      sale.itemQuantities.forEach((itemId, qty) {
        // try to resolve item details from current inventory
        String name = 'Unknown item';
        double? price;
        try {
          final it = itemController.items.firstWhere((it) => it.id == itemId);
          name = it.name;
          price = it.sellingPrice;
        } catch (_) {
          // item not found (deleted or legacy) -> leave fallback name and null price
        }

        if (!aggregated.containsKey(itemId)) {
          aggregated[itemId] = {
            'itemId': itemId,
            'name': name,
            'price': price,
            'qty': qty,
          };
        } else {
          aggregated[itemId]!['qty'] = (aggregated[itemId]!['qty'] as int) + qty;
          // keep existing name/price if present; if name was 'Unknown' but now found, prefer found one
          if ((aggregated[itemId]!['name'] as String).startsWith('Unknown') && name != 'Unknown item') {
            aggregated[itemId]!['name'] = name;
          }
          if (aggregated[itemId]!['price'] == null && price != null) {
            aggregated[itemId]!['price'] = price;
          }
        }
      });
    }

    // convert aggregated map to a list sorted by qty desc
    final soldItems = aggregated.values.map((m) {
      return {
        'itemId': m['itemId'],
        'name': m['name'],
        'price': m['price'],
        'qty': m['qty'],
      };
    }).toList()
      ..sort((a, b) => (b['qty'] as int).compareTo(a['qty'] as int));

    return WeeklySalesReport(
      startDate: start,
      endDate: end,
      totalValue: totalValue,
      totalSales: totalItemsSold,
      soldItems: soldItems,
    );
  }

  /// Generate Inventory Value Report
  InventoryValueReport generateInventoryValueReport() {
    final items = itemController.items;
    int totalItem = items.length;
    int totalQty = items.fold(0, (a, b) => a + b.quantity);
    double totalVal = items.fold(0, (a, b) => a + (b.quantity * b.sellingPrice));

    final itemSummaries = items.map((it) => {
          "name": it.name,
          "qty": it.quantity,
          "price": it.sellingPrice,
          "value": it.quantity * it.sellingPrice,
        }).toList();

    return InventoryValueReport(
      totalItem: totalItem,
      totalQuantity: totalQty,
      totalValue: totalVal,
      itemSummaries: itemSummaries, // ✅ changed field name
    );
  }
}
