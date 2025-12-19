import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easyinventory/controllers/report.controller.dart';
import '../../models/report.model.dart';

class LowStockReportPage extends StatelessWidget {
  final LowStockReport report;
  final ReportController reportController = Get.find<ReportController>();

  LowStockReportPage({
    super.key,
    required this.report,
  });

  void _exportPdf(BuildContext context) async {
    final file = await reportController.exportToPdf(
      title: 'Low Stock Report',
      fileName:
          'low_stock_${report.generatedOn.toIso8601String().substring(0, 10)}',
      headers: [
        'Item Name',
        'Quantity',
        'Avg Daily Outflow',
        'Est. Days Left',
        'Suggestion',
      ],
      rows: report.items.map((item) => [
        item['name'],
        item['qty'],
        item['avgOutflow'].toStringAsFixed(2),
        item['estDays'].toStringAsFixed(1),
        item['suggestion'],
      ]).toList(),
      summaryLines: [
        'Generated On: '
            '${report.generatedOn.day}/'
            '${report.generatedOn.month}/'
            '${report.generatedOn.year}',
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
        title: const Text("Low Stock Report"),
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
            Text(
              "Generated On "
              "${report.generatedOn.day}/"
              "${report.generatedOn.month}/"
              "${report.generatedOn.year}",
            ),
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
                        "Estimated Days Left: "
                        "${item["estDays"].toStringAsFixed(1)} days\n"
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
    );
  }
}
