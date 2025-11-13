// lib/controllers/smart_report.controller.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/smart_report.model.dart';
import 'item.controller.dart';
import 'sell.controller.dart';

class SmartReportController extends ChangeNotifier {
  final ItemController itemController;
  final SellController sellController;

  SmartReportController({
    required this.itemController,
    required this.sellController,
  });

  /// Compute average daily sales for an item over the last N days.
  double _avgDailySales(String itemId, int days) {
    if (days <= 0) return 0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    int totalQty = 0;

    for (final sale in sellController.salesHistory) {
      if (sale.date.isBefore(cutoff)) continue;
      final q = sale.itemQuantities[itemId] ?? 0;
      totalQty += q;
    }
    return totalQty / days;
  }

  List<SmartRecommendation> generate(SmartReportInput input) {
    // Parameters (tweakable rules)
    const double eventBoostPerEvent = 0.15; // +15%/event
    const double clampMultiplier = 3.0;     // cap recommendation at 3×minQuantity

    final items = itemController.items.where((it) => it.field == input.field).toList();

    final recs = <SmartRecommendation>[];

    for (final it in items) {
      // 1) Demand basis
      double baselineDaily;
      switch (input.demandMode) {
        case "avg7":
          baselineDaily = _avgDailySales(it.id, 7);
          break;
        case "avg30":
          baselineDaily = _avgDailySales(it.id, 30);
          break;
        case "manual":
          baselineDaily = (input.manualDaily ?? 0).clamp(0, double.infinity);
          break;
        default:
          baselineDaily = _avgDailySales(it.id, 30);
      }

      // If truly zero demand and we have stock, skip noisy suggestions
      if (baselineDaily == 0 && it.quantity > 0) {
        continue;
      }

      // 2) Boosts
      final eventBoost = 1 + (input.upcomingEvents * eventBoostPerEvent);
      final boostedDaily = baselineDaily * eventBoost;

      // 3) Target
      final targetStock = (boostedDaily * input.targetDays).ceil();

      // 4) Suggested restock
      int proposed = max(0, targetStock - it.quantity);

      // 5) Clamp to safety bound if minQuantity exists
      if (it.minQuantity > 0) {
        final cap = (it.minQuantity * clampMultiplier).round();
        proposed = min(proposed, max(cap, it.minQuantity)); // ensure not below min
      }

      if (proposed <= 0) continue;

      // 6) Priority
      String priority = "Low";
      if (it.quantity <= it.minQuantity) priority = "High";
      else if (it.quantity <= it.minQuantity + 3) priority = "Medium";

      // 7) Reason text
      final reason = [
        if (input.demandMode == "manual")
          "Manual daily demand ${baselineDaily.toStringAsFixed(2)}"
        else
          "Avg daily sales ${baselineDaily.toStringAsFixed(2)} (${input.demandMode})",
        if (input.upcomingEvents > 0) "+${(eventBoost - 1) * 100 ~/ 1}% for ${{input.upcomingEvents}} event(s)",
        "Target ${input.targetDays} days",
      ].join(" · ");

      recs.add(SmartRecommendation(
        itemId: it.id,
        name: it.name,
        currentStock: it.quantity,
        targetStock: targetStock,
        restockQty: proposed,
        priority: priority,
        reason: reason,
      ));
    }

    // Sort by priority then by restock size desc
    recs.sort((a, b) {
      int p(String x) => x == "High" ? 0 : x == "Medium" ? 1 : 2;
      final pc = p(a.priority).compareTo(p(b.priority));
      if (pc != 0) return pc;
      return b.restockQty.compareTo(a.restockQty);
    });

    return recs;
  }
}
