import 'package:easyinventory/views/suppliers/suppliers.dart';
import 'package:easyinventory/views/utils/global.colors.dart';
import 'package:flutter/material.dart';
import '../../controllers/sell.controller.dart';

class DashboardPage extends StatelessWidget {
  final SellController sellController;

  const DashboardPage({super.key, required this.sellController});

  @override
  Widget build(BuildContext context) {
    final todayProfit = sellController.getTodayProfit();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Title
                const Text('Dashboard',
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                //Profit Card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    color: GlobalColors.textFieldColor,
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

                //Row of buttons
                Row(
                  children: [
                    //Suppliers Button
                    Expanded(
                      child: Card(
                        color: GlobalColors.textFieldColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SuppliersPage()),
                            );
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

                    //Report Button
                    Expanded(
                      child: Card(
                        color: GlobalColors.textFieldColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            // TODO: Navigate to Report page
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
