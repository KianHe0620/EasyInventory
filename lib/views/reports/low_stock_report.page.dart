import 'package:flutter/material.dart';
import '../../models/report.model.dart';

class LowStockReportPage extends StatelessWidget {
  final LowStockReport report;

  const LowStockReportPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Low Stock Report")),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Generated On ${report.generatedOn.day}/"
                  "${report.generatedOn.month}/"
                  "${report.generatedOn.year}"),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: report.items.length,
                  itemBuilder: (ctx, i) {
                    final item = report.items[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(item["name"].toString()),
                        subtitle: Text(
                          "Quantity: ${item["qty"]} units\n"
                          "Average Daily Outflow: ${item["avgOutflow"]}/day\n"
                          "Estimated Days Left: ${item["estDays"].toStringAsFixed(1)} days\n"
                          "Suggestion: ${item["suggestion"]}",
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
