import 'package:flutter/material.dart';
import '../../controllers/sell.controller.dart';
import '../../models/sell.model.dart';

class SaleHistoryPage extends StatefulWidget {
  final SellController sellController;

  const SaleHistoryPage({super.key, required this.sellController});

  @override
  State<SaleHistoryPage> createState() => _SaleHistoryPageState();
}

class _SaleHistoryPageState extends State<SaleHistoryPage> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    // Step 1: get all sales
    var sales = widget.sellController.salesHistory.reversed.toList();

    // Step 2: filter by date if selected
    if (selectedDate != null) {
      sales = widget.sellController.filterSalesByDate(sales, selectedDate!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sale History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
          ),
          if (selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  selectedDate = null;
                });
              },
            )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedDate != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "Showing sales for: "
                "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          Expanded(
            child: sales.isEmpty
                ? const Center(child: Text("No sales found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      final date = sale.date;
                      final totalQty = sale.itemQuantities.values
                          .fold<int>(0, (a, b) => a + b);

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${date.day}/${date.month}/${date.year} "
                                "${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text("Total Value: RM ${sale.totalAmount.toStringAsFixed(2)}"),
                              Text("Total Quantity: $totalQty"),
                              const SizedBox(height: 8),
                              const Text("Items:",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              ...sale.itemQuantities.entries.map((entry) {
                                final item = widget
                                    .sellController.itemController.items
                                    .firstWhere((it) => it.id == entry.key);
                                return Text(
                                  "- ${item.name} (RM ${item.sellingPrice.toStringAsFixed(2)}) x${entry.value}",
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
