import 'package:flutter/material.dart';
import '../../controllers/item.controller.dart';
import '../../controllers/sell.controller.dart';
import '../../controllers/supplier.controller.dart';
import '../widgets/floating_add_btn.global.dart';
import 'item_add.page.dart';
import 'item_edit.page.dart';
import 'filter_sidebar.dart';
import 'bulk_update.page.dart';

class ItemsPage extends StatefulWidget {
  final ItemController itemController;
  final SellController sellController;

  const ItemsPage({
    super.key,
    required this.itemController,
    required this.sellController,
  });

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final SupplierController supplierController = SupplierController();

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.itemController.getFilteredSortedItems();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: widget.itemController.selectionMode
            ? Text('${widget.itemController.selectedIds.length} selected')
            : const Text('Items'),
        actions: [
          IconButton(
            icon: Icon(widget.itemController.selectionMode ? Icons.close : Icons.checklist),
            onPressed: () {
              setState(() => widget.itemController.toggleSelectionMode());
            },
          ),
          if (!widget.itemController.selectionMode)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
          if (widget.itemController.selectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                if (widget.itemController.selectedIds.isEmpty) {
                  setState(() => widget.itemController.toggleSelectionMode());
                  return;
                }
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm delete'),
                    content: Text('Delete ${widget.itemController.selectedIds.length} item(s)?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  setState(() => widget.itemController.deleteSelected());
                }
              },
            ),
        ],
      ),
      endDrawer: FilterSidebar(
        fields: widget.itemController.items.map((e) => e.field).toSet().toList(),
        selectedField: widget.itemController.activeFields.isEmpty
            ? null
            : widget.itemController.activeFields.first,
        sortBy: widget.itemController.sortBy,
        ascending: widget.itemController.ascending,
        onApply: (field, sortBy, asc) {
          final f = (field == null || field == "All") ? <String>{} : {field};
          setState(() => widget.itemController.applyFilter(f, sortBy!, asc));
        },
        onClear: () => setState(() => widget.itemController.resetFilters()),
      ),
      body: Column(
        children: [
          if (!widget.itemController.selectionMode)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Name or Barcode...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () {
                      // TODO: integrate barcode scanner
                    },
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => widget.itemController.setSearchQuery(v)),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, idx) {
                final item = filteredItems[idx];
                final originalIndex = widget.itemController.items.indexWhere((it) => it.id == item.id);

                return ListTile(
                  leading: widget.itemController.selectionMode
                      ? Checkbox(
                          value: widget.itemController.selectedIds.contains(item.id),
                          onChanged: (_) => setState(() => widget.itemController.toggleSelection(item.id)),
                        )
                      : (item.imagePath.isNotEmpty
                          ? Image.asset(item.imagePath, width: 40, height: 40, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 40, color: Colors.grey)),
                  title: Text(item.name),
                  subtitle: Text('Price: RM ${item.sellingPrice.toStringAsFixed(2)}'),
                  trailing: Text(
                    item.quantity.toString(),
                    style: TextStyle(
                      color: item.quantity <= item.minQuantity
                          ? Colors.red
                          : item.quantity >= item.minQuantity + 20
                              ? Colors.green
                              : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    if (widget.itemController.selectionMode) {
                      setState(() => widget.itemController.toggleSelection(item.id));
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemEditPage(
                          controller: widget.itemController,
                          supplierController: supplierController,
                          item: item,
                          index: originalIndex,
                        ),
                      ),
                    ).then((updated) {
                      if (updated != null) setState(() {});
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.itemController.selectionMode
          ? BottomAppBar(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.itemController.selectedIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No items selected")),
                          );
                          return;
                        }
                        final selectedItems = widget.itemController.items
                            .where((it) => widget.itemController.selectedIds.contains(it.id))
                            .toList();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BulkUpdatePage(
                              items: selectedItems,
                              itemController: widget.itemController,
                            ),
                          ),
                        ).then((_) => setState(() {}));
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text("Update Quantity"),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.itemController.selectedIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No items selected")),
                          );
                          return;
                        }

                        final selectedItems = widget.itemController.items
                            .where((it) => widget.itemController.selectedIds.contains(it.id))
                            .toList();

                        // ✅ Add selected items into SellController with qty = 1
                        for (final item in selectedItems) {
                          widget.sellController.setQuantity(item.id, 1);
                        }

                        // ✅ Clear selection mode
                        setState(() {
                          widget.itemController.toggleSelectionMode();
                        });

                        // ✅ Show feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Items added to cart. Go to Sell tab.")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Add to Sell"),
                    ),
                  ),
                ],
              ),
            )
          : null,
      floatingActionButton: !widget.itemController.selectionMode
          ? FloatingAddBtn(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemAddPage(
                      controller: widget.itemController,
                      supplierController: supplierController,
                    ),
                  ),
                ).then((newItem) {
                  if (newItem != null) setState(() {});
                });
              },
            )
          : null,
    );
  }
}
