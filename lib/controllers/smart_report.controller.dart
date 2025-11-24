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

  // Tunables (can be exposed in settings later)
  double eventBoostPerDay = 0.10; // 10% uplift per event-day
  double emaAlphaFloor = 0.15;
  int minNonZeroDaysForEMA = 3;
  double clampMultiplier = 3.0; // kept for legacy if needed
  // NEW: safety factor for demand-based cap
  double capSafetyFactor = 1.3; // default: 30% buffer over demand-based cap
  // Optional: absolute minimum / maximum cap boundaries (to avoid extremes)
  int? capMinLimit; // if set, advisory cap will be at least this
  int? capMaxLimit; // if set, advisory cap will not exceed this

  // -------------------------
  // Helpers: build daily counts for last N days for a given itemId
  // -------------------------
  List<int> _dailyCountsForItem(String itemId, int days) {
    final now = DateTime.now();
    // Build map Date->int for the window (oldest -> newest)
    final Map<String, int> dayMap = {};
    for (int i = 0; i < days; i++) {
      final d = now.subtract(Duration(days: days - 1 - i));
      final key = "${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}";
      dayMap[key] = 0;
    }

    for (final sale in sellController.salesHistory) {
      final d = sale.date;
      final key = "${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}";
      if (dayMap.containsKey(key)) {
        final qty = sale.itemQuantities[itemId] ?? 0;
        dayMap[key] = (dayMap[key] ?? 0) + qty;
      }
    }

    return dayMap.keys.map((k) => dayMap[k] ?? 0).toList();
  }

  double _simpleAvgDaily(String itemId, int days) {
    final list = _dailyCountsForItem(itemId, days);
    if (list.isEmpty) return 0.0;
    final tot = list.fold<int>(0, (a, b) => a + b);
    return tot / days;
  }

  double _emaDaily(String itemId, int days) {
    final list = _dailyCountsForItem(itemId, days);
    if (list.isEmpty) return 0.0;
    var alpha = 2.0 / (days + 1);
    if (alpha < emaAlphaFloor) alpha = emaAlphaFloor;
    double ema = 0.0;
    for (int i = 0; i < list.length; i++) {
      final obs = list[i].toDouble();
      if (i == 0) ema = obs;
      else ema = alpha * obs + (1 - alpha) * ema;
    }
    return ema;
  }

  Map<String, dynamic> _dailyStats(String itemId, int days) {
    final list = _dailyCountsForItem(itemId, days);
    final n = list.length;
    if (n == 0) return {'mean': 0.0, 'variance': 0.0, 'nonZero': 0};
    final tot = list.fold<int>(0, (a, b) => a + b);
    final mean = tot / n;
    double variance = 0.0;
    int nonZero = 0;
    for (final v in list) {
      if (v != 0) nonZero++;
      final d = v - mean;
      variance += d * d;
    }
    variance = variance / n;
    return {'mean': mean, 'variance': variance, 'nonZero': nonZero};
  }

  int _applyMinOrderAndPackSize(int qty, int? minOrder, int? packSize) {
    var r = qty;
    if (minOrder != null && minOrder > 1) {
      final blocks = (r / minOrder).ceil();
      r = blocks * minOrder;
    }
    if (packSize != null && packSize > 1) {
      final blocks = (r / packSize).ceil();
      r = blocks * packSize;
    }
    return r;
  }

  /// Demand-based cap: compute advisory cap based on boosted daily demand
  int _demandBasedAdvisoryCap({
    required double boostedDaily,
    required int targetDays,
    required int minQuantity,
  }) {
    // base cap from demand
    final double rawCap = boostedDaily * targetDays * capSafetyFactor;
    int cap = rawCap.ceil();

    // ensure at least minQuantity
    cap = max(cap, minQuantity);

    // apply configured bounds if present
    if (capMinLimit != null) cap = max(cap, capMinLimit!);
    if (capMaxLimit != null) cap = min(cap, capMaxLimit!);

    // final non-negative
    return max(0, cap);
  }

  List<SmartRecommendation> generate(SmartReportInput input) {
    final windowDays = (input.windowDays == null || input.windowDays! <= 0) ? 30 : input.windowDays!;
    final targetDays = (input.targetDays == null || input.targetDays! <= 0) ? 30 : input.targetDays!;
    final useFieldAll = input.field == 'All';
    final items = useFieldAll ? itemController.items : itemController.items.where((it) => it.field == input.field).toList();

    final recs = <SmartRecommendation>[];

    final eventDays = (input.upcomingEventDays != null && input.upcomingEventDays! > 0)
        ? input.upcomingEventDays!
        : (input.upcomingEvents ?? 0);
    final eventBoost = 1.0 + (eventDays * eventBoostPerDay);

    for (final it in items) {
      // Compute baseline
      double baselineDaily;
      double variance = 0.0;
      int nonZero = 0;
      {
        final stats = _dailyStats(it.id, windowDays);
        variance = (stats['variance'] as double?) ?? 0.0;
        nonZero = (stats['nonZero'] as int?) ?? 0;
        if (input.demandMode == 'manual') {
          baselineDaily = (input.manualDaily ?? 0.0);
        } else if (input.demandMode == 'avg7') {
          final d = min(windowDays, 7);
          baselineDaily = _simpleAvgDaily(it.id, d);
        } else if (input.demandMode == 'avg30') {
          final d = min(windowDays, 30);
          baselineDaily = _simpleAvgDaily(it.id, d);
        } else {
          // EMA mode
          if (nonZero < minNonZeroDaysForEMA) {
            baselineDaily = _simpleAvgDaily(it.id, windowDays);
          } else {
            final ema = _emaDaily(it.id, windowDays);
            final avg = _simpleAvgDaily(it.id, windowDays);
            baselineDaily = max(ema, avg * 0.5);
          }
        }
      }

      // If baseline effectively zero and we have stock, skip
      if (baselineDaily <= 0.0001 && it.quantity > 0) continue;

      final boostedDaily = baselineDaily * eventBoost;

      // compute targetStock with event-days only boosting
      final effectiveEventDays = min(eventDays, targetDays);
      final normalDays = max(0, targetDays - effectiveEventDays);
      final targetForNormalDays = baselineDaily * normalDays;
      final targetForEventDays = boostedDaily * effectiveEventDays;
      int targetStock = (targetForNormalDays + targetForEventDays).ceil();

      // proposed uncapped
      int proposedUncapped = max(0, targetStock - it.quantity);

      // proposed rounded (respect supplier constraints)
      int proposedRounded = _applyMinOrderAndPackSize(proposedUncapped, input.minOrder, input.packSize);

      // NEW: demand-based advisory cap (replaces minQty * 3 simple cap)
      final advisoryCapped = _demandBasedAdvisoryCap(
        boostedDaily: boostedDaily,
        targetDays: targetDays,
        minQuantity: it.minQuantity,
      );

      // if you still want to keep a minimum safety floor tied to minQuantity * clampMultiplier,
      // you can combine both strategies: finalAdvisory = max(advisoryCapped, minQuantity*clampMultiplier)
      // For now we prefer pure demand-based:
      final proposedCapped = min(proposedRounded, advisoryCapped);

      final hitCap = proposedRounded > advisoryCapped;

      // pick final restock suggestion depending on enforceCap flag
      final restockQty = input.enforceCap ? proposedCapped : proposedRounded;

      // priority
      String priority = "Low";
      if (it.quantity <= it.minQuantity) priority = "High";
      else if (it.quantity <= it.minQuantity + 3) priority = "Medium";

      // confidence heuristic
      double confidence;
      {
        final mean = baselineDaily;
        final stddev = sqrt(max(0.0, variance));
        final noise = stddev / (mean + 1.0);
        confidence = (1.0 - noise).clamp(0.05, 0.99);
      }

      String reason =
          "Baseline ${baselineDaily.toStringAsFixed(2)}/d (${input.demandMode}) · +${((eventBoost - 1) * 100).toStringAsFixed(0)}% for ${effectiveEventDays} event-day(s) · Target ${targetDays}d";

      final rec = SmartRecommendation(
        itemId: it.id,
        name: it.name,
        currentStock: it.quantity,
        targetStock: targetStock,
        restockQty: restockQty,
        advisoryCappedQty: proposedCapped,
        hitCap: hitCap,
        priority: priority,
        reason: reason,
        baselineDaily: baselineDaily,
        boostedDaily: boostedDaily,
        cap: advisoryCapped,
        confidence: confidence,
        variance: variance,
        consideredWindowDays: windowDays,
        nonZeroSampleDays: nonZero,
      );

      // Include items that either have non-zero restock or hitCap so owner sees advisory
      if (restockQty > 0 || hitCap) {
        recs.add(rec);
      }
    }

    // sort by priority then restock desc
    recs.sort((a, b) {
      int p(String x) => x == "High" ? 0 : x == "Medium" ? 1 : 2;
      final c = p(a.priority).compareTo(p(b.priority));
      if (c != 0) return c;
      return b.restockQty.compareTo(a.restockQty);
    });

    return recs;
  }
}
