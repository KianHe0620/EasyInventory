import 'package:flutter/material.dart';
import '../../models/report.model.dart';

class InventoryValueReportPage extends StatelessWidget {
  final InventoryValueReport report;

  const InventoryValueReportPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory Value Report")),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Item: ${report.totalItem}"),
              Text("Total Quantity: ${report.totalQuantity}"),
              Text("Total Value (RM): ${report.totalValue.toStringAsFixed(2)}"),
              const SizedBox(height: 16),
              const Text("AI Overstock Items Insight",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: report.overstockItems.length,
                  itemBuilder: (ctx, i) {
                    final item = report.overstockItems[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(item["name"].toString()),
                        subtitle: Text(
                          "Stock: ${item["qty"]}\n"
                          "Avg Outflow: ${item["avgOutflow"]}/day\n"
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
