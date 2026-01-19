import 'package:easyinventory/controllers/report.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/report.model.dart';

class WeeklySalesReportPage extends StatelessWidget {
  final WeeklySalesReport report;
  final ReportController reportController = Get.find<ReportController>();

  WeeklySalesReportPage({
    super.key, 
    required this.report
    });

  void _downloadReport(BuildContext context) async {
    final file = await reportController.exportToPdf(
      title: 'Weekly Sales Report',
      fileName:
          'weekly_sales_${report.startDate.toIso8601String().substring(0, 10)}',
      headers: ['Item Name', 'Price (RM)', 'Quantity Sold'],
      rows: report.soldItems.map((e) => [
        e['name'],
        e['price']?.toStringAsFixed(2) ?? '-',
        e['qty'],
      ]).toList(),
      summaryLines: [
        'Period: ${report.startDate} - ${report.endDate}',
        'Total Sales: ${report.totalSales}',
        'Total Value (RM): ${report.totalValue.toStringAsFixed(2)}',
      ],
    );

    Get.snackbar('Success', 'PDF saved in Downloads:\n${file.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Weekly Sales Report"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Download Report",
            onPressed: () => _downloadReport(context),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${report.startDate.day}/${report.startDate.month}/${report.startDate.year} "
                "- ${report.endDate.day}/${report.endDate.month}/${report.endDate.year}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Total Sales: ${report.totalSales}"),
              Text("Total Value (RM): ${report.totalValue.toStringAsFixed(2)}"),
              const SizedBox(height: 16),
              const Text("Sold Items", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Price (RM)")),
                      DataColumn(label: Text("Qty")),
                    ],
                    rows: report.soldItems
                        .map((e) => DataRow(cells: [
                              DataCell(Text(e["name"].toString())),
                              DataCell(Text(e["price"].toString())),
                              DataCell(Text(e["qty"].toString())),
                            ]))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
