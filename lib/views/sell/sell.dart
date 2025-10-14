import 'package:flutter/material.dart';
import '../../controllers/item.controller.dart';
import '../../controllers/sell.controller.dart';
import '../sell/sale_history.page.dart';
import '../widgets/quantity_box.global.dart';

class SellPage extends StatefulWidget {
  final ItemController itemController;
  final SellController sellController; // ✅ passed from ItemsPage

  const SellPage({
    super.key,
    required this.itemController,
    required this.sellController,
  });

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  late SellController sellController;

  @override
  void initState() {
    super.initState();
    sellController = widget.sellController; // ✅ use shared instance
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = widget.itemController.items
        .where((it) => sellController.getQuantity(it.id) > 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.barcode_reader),
            onPressed: () {
              // TODO: integrate barcode scanner
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SaleHistoryPage(sellController: sellController),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text("Cart is empty. Add items first."))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, idx) {
                      final it = cartItems[idx];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            it.imagePath.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      it.imagePath,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.image,
                                    size: 50, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(it.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('RM ${it.sellingPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Colors.black54, fontSize: 14)),
                                ],
                              ),
                            ),
                            QuantityBox(
                              label: '',
                              value: sellController.getQuantity(it.id),
                              onChanged: (val) {
                                setState(() {
                                  sellController.setQuantity(it.id, val);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total: RM ${sellController.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    if (sellController.saleQuantities.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Cart is empty! Please add items.")),
                      );
                      return;
                    }

                    final err = sellController.validate();
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err)),
                      );
                      return;
                    }

                    final sale = sellController.commitSale();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sale completed'),
                        content: Text(
                          'Sold items:\n${sale.itemQuantities.entries.map((e) {
                            final it = widget.itemController.items
                                .firstWhere((it) => it.id == e.key);
                            return '${it.name}: ${e.value}';
                          }).join('\n')}\n\nTotal: RM ${sale.totalAmount.toStringAsFixed(2)}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('OK'),
                          )
                        ],
                      ),
                    );
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Confirm Sale'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
