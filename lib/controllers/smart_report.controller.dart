import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

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

  // =========================
  // Tunables
  // =========================
  double eventBoostPerDay = 0.10;
  double emaAlphaFloor = 0.15;
  int minNonZeroDaysForEMA = 3;
  double capSafetyFactor = 1.3;

  int? capMinLimit;
  int? capMaxLimit;

  // =========================
  // Demand helpers
  // =========================
  List<int> _dailyCountsForItem(String itemId, int days) {
    final now = DateTime.now();
    final Map<String, int> dayMap = {};

    for (int i = 0; i < days; i++) {
      final d = now.subtract(Duration(days: days - 1 - i));
      final key =
          "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      dayMap[key] = 0;
    }

    for (final sale in sellController.salesHistory) {
      final d = sale.date;
      final key =
          "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      if (dayMap.containsKey(key)) {
        dayMap[key] = (dayMap[key] ?? 0) + (sale.itemQuantities[itemId] ?? 0);
      }
    }

    return dayMap.values.toList();
  }

  double _simpleAvgDaily(String itemId, int days) {
    final list = _dailyCountsForItem(itemId, days);
    if (list.isEmpty) return 0.0;
    return list.reduce((a, b) => a + b) / days;
  }

  double _emaDaily(String itemId, int days) {
    final list = _dailyCountsForItem(itemId, days);
    if (list.isEmpty) return 0.0;

    double alpha = max(emaAlphaFloor, 2 / (days + 1));
    double ema = list.first.toDouble();

    for (int i = 1; i < list.length; i++) {
      ema = alpha * list[i] + (1 - alpha) * ema;
    }
    return ema;
  }

  int _demandBasedCap({
    required double boostedDaily,
    required int targetDays,
    required int minQty,
  }) {
    int cap = (boostedDaily * targetDays * capSafetyFactor).ceil();
    cap = max(cap, minQty);
    if (capMinLimit != null) cap = max(cap, capMinLimit!);
    if (capMaxLimit != null) cap = min(cap, capMaxLimit!);
    return max(0, cap);
  }

  // =========================
  // MAIN GENERATION
  // =========================
  List<SmartRecommendation> generate(SmartReportInput input) {
    final windowDays = input.windowDays ?? 30;
    final targetDays = input.targetDays ?? 30;
    final items = input.field == 'All'
        ? itemController.items
        : itemController.items.where((i) => i.field == input.field).toList();

    final eventDays = input.upcomingEventDays ?? 0;
    final eventBoost = 1 + (eventDays * eventBoostPerDay);

    final List<SmartRecommendation> recs = [];

    for (final it in items) {
      final baseline = input.demandMode == 'ema'
          ? _emaDaily(it.id, windowDays)
          : _simpleAvgDaily(it.id, windowDays);

      if (baseline <= 0 && it.quantity > 0) continue;

      final boosted = baseline * eventBoost;
      final targetStock = (boosted * targetDays).ceil();
      final uncapped = max(0, targetStock - it.quantity);

      final cap = _demandBasedCap(
        boostedDaily: boosted,
        targetDays: targetDays,
        minQty: it.minQuantity,
      );

      final restock = input.enforceCap ? min(uncapped, cap) : uncapped;
      final hitCap = uncapped > cap;

      final priority = it.quantity <= it.minQuantity
          ? 'High'
          : it.quantity <= it.minQuantity + 3
              ? 'Medium'
              : 'Low';

      recs.add(
        SmartRecommendation(
          itemId: it.id,
          name: it.name,
          currentStock: it.quantity,
          targetStock: targetStock,
          restockQty: restock,
          advisoryCappedQty: cap,
          hitCap: hitCap,
          priority: priority,
          reason: 'Smart demand-based restock calculation',
          baselineDaily: baseline,
          boostedDaily: boosted,
          cap: cap,
          confidence: 0.8,
          variance: 0,
          consideredWindowDays: windowDays,
          nonZeroSampleDays: 0,
        ),
      );
    }

    recs.sort((a, b) {
      int p(String s) => s == 'High' ? 0 : s == 'Medium' ? 1 : 2;
      return p(a.priority).compareTo(p(b.priority));
    });

    return recs;
  }

  // =========================
  // SPECIAL SMART REPORT PDF
  // =========================
  Future<File> exportSmartReportPdf({
    required SmartReportInput input,
    required List<SmartRecommendation> recs,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) {
          return [
            pw.Text(
              'Smart Restock Report',
              style:
                  pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Generated on: ${DateTime.now()}'),
            pw.Divider(),

            pw.Text('Input Summary',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: 'Field: ${input.field}'),
            pw.Bullet(text: 'Demand Mode: ${input.demandMode}'),
            pw.Bullet(text: 'Target Days: ${input.targetDays ?? 30}'),
            pw.Bullet(text: 'Analysis Window: ${input.windowDays ?? 30}'),
            pw.Bullet(
                text: input.enforceCap
                    ? 'Safety Cap: Enforced'
                    : 'Safety Cap: Advisory'),

            pw.SizedBox(height: 12),

            pw.Table.fromTextArray(
              headers: [
                'Item',
                'Current',
                'Target',
                'Suggested',
                'Cap',
                'Priority'
              ],
              data: recs
                  .map((r) => [
                        r.name,
                        r.currentStock,
                        r.targetStock,
                        r.restockQty,
                        r.advisoryCappedQty,
                        r.priority,
                      ])
                  .toList(),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
            ),
          ];
        },
      ),
    );

    final dir = Platform.isAndroid
        ? Directory('/storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();

    final file = File(
        '${dir.path}/smart_report_${DateTime.now().toIso8601String().substring(0, 10)}.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
