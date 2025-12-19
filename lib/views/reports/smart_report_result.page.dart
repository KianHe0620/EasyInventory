import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/smart_report.model.dart';
import 'package:get/get.dart';
import 'package:easyinventory/controllers/smart_report.controller.dart';

class SmartReportResultPage extends StatefulWidget {
  final SmartReportInput input;
  final List<SmartRecommendation> recommendations;

  SmartReportResultPage({
    super.key,
    required this.input,
    required this.recommendations,
  });

  @override
  State<SmartReportResultPage> createState() => _SmartReportResultPageState();
}

class _SmartReportResultPageState extends State<SmartReportResultPage> {
  // per-item local override (when user taps "Apply cap")
  final Map<String, int> _appliedOverrides = {};
  final SmartReportController smartReportController = Get.find<SmartReportController>();

  void _applyCap(SmartRecommendation r) {
    setState(() {
      _appliedOverrides[r.itemId] = r.advisoryCappedQty;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Applied cap for ${r.name}: ${r.advisoryCappedQty}')));
  }

  @override
  Widget build(BuildContext context) {
    final recs = widget.recommendations;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Smart Report Result"),
        actions: [
          IconButton(
            tooltip: 'Export PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final file = await smartReportController.exportSmartReportPdf(
                input: widget.input,
                recs: widget.recommendations,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('PDF saved in Downloads:\n${file.path}'),
                ),
              );
            },
          ),
        ],
      ),
      body: recs.isEmpty
          ? const Center(child: Text("No recommendations for the selected inputs."))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: recs.length,
              itemBuilder: (ctx, i) {
                final r = recs[i];
                final displayed = _appliedOverrides[r.itemId] ?? r.restockQty;
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(
                        children: [
                          Expanded(child: Text(r.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                          Chip(label: Text(r.priority, style: const TextStyle(color: Colors.white)), backgroundColor: r.priority == "High" ? Colors.red : r.priority == "Medium" ? Colors.orange : Colors.grey)
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${r.reason}'),
                      const SizedBox(height: 8),
                      Text('Now ${r.currentStock} → Target ${r.targetStock}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Divider(),
                      Row(children: [
                        Expanded(child: _smallInfo('Baseline', '${r.baselineDaily.toStringAsFixed(2)}/d')),
                        Expanded(child: _smallInfo('Boosted', '${r.boostedDaily.toStringAsFixed(2)}/d')),
                        Expanded(child: _smallInfo('Confidence', '${(r.confidence * 100).toStringAsFixed(1)}%')),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: _smallInfo('Variance', r.variance.toStringAsFixed(2))),
                        Expanded(child: _smallInfo('Cap', r.cap?.toString() ?? '-')),
                        Expanded(child: _smallInfo('NonZeroDays', r.nonZeroSampleDays.toString())),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: Text('Suggested: $displayed', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 8),
                        if (r.hitCap) ...[
                          ElevatedButton(
                            onPressed: () => _applyCap(r),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            child: const Text('Apply cap'),
                          ),
                        ]
                      ]),
                      if (r.hitCap)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Advisory cap suggestion: ${r.advisoryCappedQty} (recommended maximum)', style: const TextStyle(color: Colors.grey)),
                        ),
                    ]),
                  ),
                );
              },
            ),
    );
  }

  Widget _smallInfo(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
