// lib/views/reports/smart_report_result.page.dart
import 'package:flutter/material.dart';
import '../../models/smart_report.model.dart';

class SmartReportResultPage extends StatelessWidget {
  final SmartReportInput input;
  final List<SmartRecommendation> recommendations;

  const SmartReportResultPage({
    super.key,
    required this.input,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Report Result"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Export CSV",
            onPressed: () {
              final buf = StringBuffer()
                ..writeln("Item,Current,Target,Restock,Priority,Reason");
              for (final r in recommendations) {
                buf.writeln(
                    "${r.name},${r.currentStock},${r.targetStock},${r.restockQty},${r.priority},\"${r.reason}\"");
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("CSV ready:\n${buf.toString()}")),
              );
            },
          )
        ],
      ),
      body: SizedBox.expand(
        child: recommendations.isEmpty
            ? const Center(child: Text("No recommendations for the selected inputs."))
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: recommendations.length,
                itemBuilder: (_, i) {
                  final r = recommendations[i];
                  return Card(
                    child: ListTile(
                      title: Text(r.name),
                      subtitle: Text(r.reason),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Restock: ${r.restockQty}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("Now ${r.currentStock} → Target ${r.targetStock}"),
                          Text(r.priority, style: TextStyle(
                            color: r.priority == "High"
                              ? Colors.red
                              : r.priority == "Medium"
                                ? Colors.orange
                                : Colors.grey,
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
