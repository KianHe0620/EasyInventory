// lib/models/smart_report.model.dart
class SmartReportInput {
  final String field;            // e.g. "Food"
  final int upcomingEvents;      // e.g. 0..N
  final String demandMode;       // "avg7", "avg30", "manual"
  final double? manualDaily;     // used when demandMode == "manual"
  final int targetDays;          // default 30

  SmartReportInput({
    required this.field,
    required this.upcomingEvents,
    required this.demandMode,
    this.manualDaily,
    this.targetDays = 30,
  });
}

class SmartRecommendation {
  final String itemId;
  final String name;
  final int currentStock;
  final int targetStock;
  final int restockQty;
  final String priority;   // "High" | "Medium" | "Low"
  final String reason;

  SmartRecommendation({
    required this.itemId,
    required this.name,
    required this.currentStock,
    required this.targetStock,
    required this.restockQty,
    required this.priority,
    required this.reason,
  });
}
