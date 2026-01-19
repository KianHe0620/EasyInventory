import 'package:easyinventory/controllers/smart_report.controller.dart';
import 'package:easyinventory/views/reports/reports.page.dart';
import 'package:easyinventory/views/suppliers/suppliers.page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sell.controller.dart';
import '../../controllers/item.controller.dart';
import '../../controllers/report.controller.dart';

class DashboardPage extends StatelessWidget {

  DashboardPage({super.key,});

  final SellController sellController = Get.find<SellController>();
  final ItemController itemController = Get.find<ItemController>();

  @override
  Widget build(BuildContext context) {
    final todayProfit = sellController.getTodayProfit();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 34, 
            fontWeight: FontWeight.bold
          ),
        )
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profit Card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    color: const Color(0xFFF2F2F2),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text("Today's Profit"),
                          const SizedBox(height: 10),
                          Text(
                            "RM ${todayProfit.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // Row of buttons
                Row(
                  children: [
                    // Suppliers Button
                    Expanded(
                      child: Card(
                        color: const Color(0xFFF2F2F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.to(() => const SuppliersPage());
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Icon(Icons.group, size: 40),
                                SizedBox(height: 8),
                                Text("Suppliers")
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Report Button
                    Expanded(
                      child: Card(
                        color: const Color(0xFFF2F2F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            final reportController = ReportController(
                              itemController: itemController,
                              sellController: sellController,
                            );

                            final smartReportController = SmartReportController(
                              itemController: itemController,
                              sellController: sellController,
                            );

                            Get.to(() => ReportPage(
                                reportController: reportController,
                                smartReportController: smartReportController,
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Icon(Icons.bar_chart, size: 40),
                                SizedBox(height: 8),
                                Text("Report")
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
