import 'package:flutter/material.dart';
import '../../controllers/item.controller.dart';
import '../../models/item.model.dart';

class BulkUpdatePage extends StatefulWidget {
  final List<Item> items;
  final ItemController itemController;

  const BulkUpdatePage({
    super.key,
    required this.items,
    required this.itemController,
  });

  @override
  State<BulkUpdatePage> createState() => _BulkUpdatePageState();
}

class _BulkUpdatePageState extends State<BulkUpdatePage> {
  late Map<String, int> updatedQuantities;

  @override
  void initState() {
    super.initState();
    updatedQuantities = {for (var it in widget.items) it.id: it.quantity};
  }

  void applyChanges() {
    updatedQuantities.forEach((id, qty) {
      final idx = widget.itemController.items.indexWhere((it) => it.id == id);
      if (idx != -1) {
        final updated = widget.itemController.items[idx].copyWith(quantity: qty);
        widget.itemController.updateItem(idx, updated);
      }
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bulk Update"),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: applyChanges),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (ctx, idx) {
          final item = widget.items[idx];
          final qty = updatedQuantities[item.id] ?? item.quantity;

          return ListTile(
            leading: item.imagePath.isNotEmpty
                ? Image.asset(item.imagePath, width: 40, height: 40, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 40, color: Colors.grey),
            title: Text(item.name),
            subtitle: Text("Price: RM ${item.sellingPrice.toStringAsFixed(2)}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      updatedQuantities[item.id] = (qty - 1).clamp(0, 9999);
                    });
                  },
                ),
                Text(
                  qty.toString(),
                  style: TextStyle(
                    color: qty <= item.minQuantity
                        ? Colors.red
                        : qty >= item.minQuantity + 20
                            ? Colors.green
                            : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      updatedQuantities[item.id] = qty + 1;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
