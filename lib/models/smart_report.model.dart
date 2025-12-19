class SmartReportInput {
  final String field;
  final String demandMode;
  final double? manualDaily;
  final int? upcomingEvents;
  final int? upcomingEventDays;
  final int? targetDays;
  final int? windowDays;
  final int? minOrder;
  final int? packSize;

  /// When true, apply safety cap as a hard enforcement.
  /// Default false (cap is advisory / suggestion).
  final bool enforceCap;

  SmartReportInput({
    required this.field,
    this.demandMode = 'avg30',
    this.manualDaily,
    this.upcomingEvents,
    this.upcomingEventDays,
    this.targetDays,
    this.windowDays,
    this.minOrder,
    this.packSize,
    this.enforceCap = false,
  });
}

class SmartRecommendation {
  final String itemId;
  final String name;
  final int currentStock;
  final int targetStock;
  /// restockQty is the value that UI should use as the main suggestion
  /// (either capped or uncapped depending on enforceCap).
  final int restockQty;

  /// advisoryCappedQty is the capped value (safety cap applied).
  /// Show it as an advisory suggestion in UI.
  final int advisoryCappedQty;

  /// whether the uncapped suggestion would hit the cap
  final bool hitCap;

  final String priority;
  final String reason;

  // explainability / diagnostics
  final double baselineDaily;
  final double boostedDaily;
  final int? cap;
  final double confidence;
  final double variance;
  final int consideredWindowDays;
  final int nonZeroSampleDays;

  SmartRecommendation({
    required this.itemId,
    required this.name,
    required this.currentStock,
    required this.targetStock,
    required this.restockQty,
    required this.advisoryCappedQty,
    required this.hitCap,
    required this.priority,
    required this.reason,
    required this.baselineDaily,
    required this.boostedDaily,
    required this.cap,
    required this.confidence,
    required this.variance,
    required this.consideredWindowDays,
    required this.nonZeroSampleDays,
  });
}
