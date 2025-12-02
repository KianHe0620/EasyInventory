// lib/views/items/bulk_update.page.dart
import 'dart:io';
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

  /// Return a widget that shows a thumbnail for the given imagePath.
  /// - local file path -> Image.file
  /// - http(s) url -> Image.network
  /// - non-empty string (assume asset key) -> Image.asset
  /// - empty/null -> placeholder icon
  Widget _buildThumb(String? imagePath, {double size = 40}) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.image, size: size * 0.6, color: Colors.grey),
      );
    }

    // Try as local file
    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: size,
              height: size,
              color: Colors.grey.shade200,
              child: Icon(Icons.broken_image, size: size * 0.6, color: Colors.grey),
            ),
          ),
        );
      }
    } catch (_) {
      // on platforms that don't support dart:io (web), this will throw -
      // fall through to network/asset handling.
    }

    // Try as network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: size,
            height: size,
            color: Colors.grey.shade200,
            child: Icon(Icons.broken_image, size: size * 0.6, color: Colors.grey),
          ),
        ),
      );
    }

    // Otherwise assume it's an asset key packaged with the app.
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          child: Icon(Icons.broken_image, size: size * 0.6, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            leading: _buildThumb(item.imagePath, size: 48),
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
