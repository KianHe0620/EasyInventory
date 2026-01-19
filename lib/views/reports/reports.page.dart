import 'package:flutter/material.dart';
import 'package:easyinventory/controllers/report.controller.dart';
import 'package:easyinventory/controllers/smart_report.controller.dart';
import 'package:easyinventory/views/reports/inventory_value_report.page.dart';
import 'package:easyinventory/views/reports/low_stock_report.page.dart';
import 'package:easyinventory/views/reports/weekly_sales_report.page.dart';
import 'package:easyinventory/views/reports/smart_report_form.page.dart';
import 'package:get/get.dart';

class ReportPage extends StatelessWidget {
  final ReportController reportController;
  final SmartReportController smartReportController;

  const ReportPage({
    super.key,
    required this.reportController,
    required this.smartReportController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Reports")
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Weekly Sales Report"),
            onTap: () {
              final report = reportController.generateWeeklySalesReport(
                DateTime.now().subtract(const Duration(days: 7)),
                DateTime.now(),
              );
              Get.to(() => WeeklySalesReportPage(report: report));
            },
          ),
          ListTile(
            title: const Text("Inventory Value Report"),
            onTap: () {
              final report = reportController.generateInventoryValueReport();
              Get.to(() => InventoryValueReportPage(report: report));
            },
          ),
          ListTile(
            title: const Text("Low Stock Report"),
            onTap: () {
              final report = reportController.generateLowStockReport();
              Get.to(() => LowStockReportPage(report: report));
            },
          ),
        ],
      ),

      //Smart Report Button
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.auto_graph),
        label: const Text("Smart Report"),
        onPressed: () {
          Get.to(() => SmartReportFormPage());
        },
      ),
    );
  }
}
