import 'package:flutter/material.dart';
import '../../models/report.model.dart';

class WeeklySalesReportPage extends StatelessWidget {
  final WeeklySalesReport report;

  const WeeklySalesReportPage({super.key, required this.report});

  void _downloadReport(BuildContext context) {
    // Simple mock: convert to CSV string
    final csvBuffer = StringBuffer();
    csvBuffer.writeln("Name,Price,Qty");
    for (var item in report.soldItems) {
      csvBuffer.writeln(
        "${item["name"]},${item["price"]},${item["qty"]}",
      );
    }

    // Show snackbar for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Report exported:\n${csvBuffer.toString()}"),
        duration: const Duration(seconds: 3),
      ),
    );

    // TODO:
    // - Save CSV locally using path_provider
    // - Or share using share_plus
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Sales Report"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
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
