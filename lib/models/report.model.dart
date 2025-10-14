class Report {
  final String id;
  final String type; // e.g. "weekly_sales", "low_stock", "inventory_value"
  final DateTime generatedOn;
  final Map<String, dynamic> data; // flexible payload

  Report({
    required this.id,
    required this.type,
    required this.generatedOn,
    required this.data,
  });
}

class WeeklySalesReport {
  final DateTime startDate;
  final DateTime endDate;
  final double totalValue;
  final int totalSales;
  final List<Map<String, dynamic>> soldItems; // {name, price, qty}

  WeeklySalesReport({
    required this.startDate,
    required this.endDate,
    required this.totalValue,
    required this.totalSales,
    required this.soldItems,
  });
}

class LowStockReport {
  final DateTime generatedOn;
  final List<Map<String, dynamic>> items; // {name, qty, avgOutflow, estDays, suggestion}

  LowStockReport({required this.generatedOn, required this.items});
}

class InventoryValueReport {
  final int totalItem;
  final int totalQuantity;
  final double totalValue;
  final List<Map<String, dynamic>> overstockItems;

  InventoryValueReport({
    required this.totalItem,
    required this.totalQuantity,
    required this.totalValue,
    required this.overstockItems,
  });
}
