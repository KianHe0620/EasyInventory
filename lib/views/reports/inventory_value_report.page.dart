import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easyinventory/controllers/report.controller.dart';
import '../../models/report.model.dart';

class InventoryValueReportPage extends StatelessWidget {
  final InventoryValueReport report;
  final ReportController reportController = Get.find<ReportController>();

  InventoryValueReportPage({
    super.key,
    required this.report,
  });

  void _exportPdf(BuildContext context) async {
    final file = await reportController.exportToPdf(
      title: 'Inventory Value Report',
      fileName: 'inventory_value_report',
      headers: [
        'Item Name',
        'Quantity',
        'Price (RM)',
        'Value (RM)',
      ],
      rows: report.itemSummaries.map((item) => [
        item['name'],
        item['qty'],
        item['price'].toStringAsFixed(2),
        item['value'].toStringAsFixed(2),
      ]).toList(),
      summaryLines: [
        'Total Items: ${report.totalItem}',
        'Total Quantity: ${report.totalQuantity}',
        'Total Value (RM): ${report.totalValue.toStringAsFixed(2)}',
      ],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved in Downloads:\n${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Inventory Value Report"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Export PDF",
            onPressed: () => _exportPdf(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Item: ${report.totalItem}"),
            Text("Total Quantity: ${report.totalQuantity}"),
            Text(
              "Total Value (RM): "
              "${report.totalValue.toStringAsFixed(2)}",
            ),
            const SizedBox(height: 16),
            const Text(
              "Item Summary",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: report.itemSummaries.length,
                itemBuilder: (ctx, i) {
                  final item = report.itemSummaries[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(item["name"].toString()),
                      subtitle: Text(
                        "Stock: ${item["qty"]}\n"
                        "Price: RM ${item["price"].toStringAsFixed(2)}\n"
                        "Value: RM ${item["value"].toStringAsFixed(2)}",
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
