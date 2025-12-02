import 'dart:io';
import 'package:flutter/material.dart';
import '../../controllers/item.controller.dart';
import '../../controllers/sell.controller.dart';
import '../sell/sale_history.page.dart';
import '../widgets/quantity_box.global.dart';
import 'package:easyinventory/views/utils/barcode_scanner.utils.dart';
import '../../models/item.model.dart';

class SellPage extends StatefulWidget {
  final ItemController itemController;
  final SellController sellController;

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
  bool _isCommitting = false;

  @override
  void initState() {
    super.initState();
    sellController = widget.sellController;
    widget.itemController.addListener(_onDataChanged);
    sellController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    widget.itemController.removeListener(_onDataChanged);
    sellController.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _scanAndAddToCart() async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );

    if (result == null || result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Barcode scan cancelled')));
      return;
    }

    final matched = widget.itemController.items.where((it) => it.barcode == result).toList();
    if (matched.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No item found for barcode: $result')));
      return;
    }

    final item = matched.first;
    final currentQty = sellController.getQuantity(item.id);
    sellController.setQuantity(item.id, currentQty + 1);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added "${item.name}" x1 to cart')));
    setState(() {});
  }

  Widget _buildItemThumb(String? imagePath, {double size = 50}) {
    if (imagePath == null || imagePath.isEmpty) {
      return Icon(Icons.image, size: size, color: Colors.grey);
    }

    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(file, width: size, height: size, fit: BoxFit.cover),
        );
      }
    } catch (_) {}

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(imagePath, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
          return Icon(Icons.broken_image, size: size, color: Colors.grey);
        }),
      );
    }

    return Icon(Icons.image, size: size, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = widget.itemController.items
        .where((it) => sellController.getQuantity(it.id) > 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Sell Items',
          style: TextStyle(
            fontSize: 34, 
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.barcode_reader),
            onPressed: _scanAndAddToCart,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) =>
                SaleHistoryPage(
                  sellController: sellController,
                  itemController: widget.itemController,
                ),
              ));
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
                            _buildItemThumb(it.imagePath, size: 64),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(it.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('RM ${it.sellingPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(color: Colors.black54, fontSize: 14)),
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
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade300))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Total: RM ${sellController.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isCommitting ? null : () async {
                    if (sellController.saleQuantities.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cart is empty! Please add items.")));
                      return;
                    }
                    final err = sellController.validate();
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                      return;
                    }

                    setState(() => _isCommitting = true);
                    try {
                      final sale = await sellController.commitSale();

                      if (!mounted) return;
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Sale completed'),
                          content: Text(
                            'Sold items:\n${sale.itemQuantities.entries.map((e) {
                              final it = widget.itemController.items.firstWhere(
                                (item) => item.id == e.key,
                                orElse: () => Item(
                                  id: '',
                                  name: 'Unknown',
                                  quantity: 0,
                                  minQuantity: 0,
                                  purchasePrice: 0,
                                  sellingPrice: 0,
                                  barcode: '',
                                  supplier: '',
                                  field: '',
                                  imagePath: '',
                                ),
                              );
                              return '${it.name}: ${e.value}';
                            }).join('\n')}\n\nTotal: RM ${sale.totalAmount.toStringAsFixed(2)}',
                          ),
                          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                        ),
                      );
                      if (mounted) setState(() {});
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sale failed: ${e.toString()}')));
                    } finally {
                      if (mounted) setState(() => _isCommitting = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF0A84D0)
                  ),
                  child: _isCommitting
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text(
                    'Confirm Sale',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
