import 'dart:io';
import 'package:easyinventory/views/utils/barcode_scanner.utils.dart';
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
  final SupplierController supplierController;

  const ItemsPage({
    super.key,
    required this.itemController,
    required this.sellController,
    required this.supplierController,
  });

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to controller notifications to rebuild when data changes
    widget.itemController.addListener(_onControllerChanged);
    widget.supplierController.addListener(_onControllerChanged);

    // keep search text in sync
    _searchCtrl.text = widget.itemController.searchQuery;
    _searchCtrl.addListener(() {
      widget.itemController.setSearchQuery(_searchCtrl.text);
      setState(() {}); // to update clear button visibility
    });
  }

  @override
  void dispose() {
    widget.itemController.removeListener(_onControllerChanged);
    widget.supplierController.removeListener(_onControllerChanged);
    _searchCtrl.removeListener(() {});
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Widget _buildItemLeading(String imagePath) {
    if (imagePath.isNotEmpty) {
      // network image
      if (imagePath.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imagePath,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48),
          ),
        );
      }

      // local file path
      try {
        final file = File(imagePath);
        if (file.existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48),
            ),
          );
        }
      } catch (_) {
        // ignore and fall through to placeholder
      }
    }

    // fallback icon
    return const SizedBox(
      width: 48,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFEEEEEE),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Icon(Icons.image, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemCtrl = widget.itemController;
    final supplierCtrl = widget.supplierController;
    final sellCtrl = widget.sellController;

    final filteredItems = itemCtrl.getFilteredSortedItems();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: itemCtrl.selectionMode
            ? Text('${itemCtrl.selectedIds.length} selected')
            : const Text('Items'),
        actions: [
          IconButton(
            icon: Icon(itemCtrl.selectionMode ? Icons.close : Icons.checklist),
            onPressed: () {
              setState(() => itemCtrl.toggleSelectionMode());
            },
          ),
          if (!itemCtrl.selectionMode)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
          if (itemCtrl.selectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                if (itemCtrl.selectedIds.isEmpty) {
                  setState(() => itemCtrl.toggleSelectionMode());
                  return;
                }
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm delete'),
                    content: Text('Delete ${itemCtrl.selectedIds.length} item(s)?'),
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
                  setState(() => itemCtrl.deleteSelected());
                }
              },
            ),
        ],
      ),
      endDrawer: FilterSidebar(
        fields: itemCtrl.items.map((e) => e.field).toSet().toList(),
        selectedField: itemCtrl.activeFields.isEmpty ? null : itemCtrl.activeFields.first,
        sortBy: itemCtrl.sortBy,
        ascending: itemCtrl.ascending,
        onApply: (field, sortBy, asc) {
          final f = (field == null || field == "All") ? <String>{} : {field};
          setState(() => itemCtrl.applyFilter(f, sortBy!, asc));
        },
        onClear: () => setState(() => itemCtrl.resetFilters()),
      ),
      body: Column(
        children: [
          if (!itemCtrl.selectionMode)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Name or Barcode...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchCtrl.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            itemCtrl.setSearchQuery('');
                            setState(() {});
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: () async {
                          // navigate to barcode scanner and apply result
                          final result = await Navigator.push<String?>(
                            context,
                            MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
                          );
                          if (result != null && result.isNotEmpty) {
                            _searchCtrl.text = result;
                            itemCtrl.setSearchQuery(result);
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => itemCtrl.setSearchQuery(v),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: filteredItems.length,
              itemBuilder: (context, idx) {
                final item = filteredItems[idx];
                // find original index in the backing items list, needed for updateItem(index,...)
                final originalIndex = itemCtrl.items.indexWhere((it) => it.id == item.id);

                return ListTile(
                  leading: itemCtrl.selectionMode
                      ? Checkbox(
                          value: itemCtrl.selectedIds.contains(item.id),
                          onChanged: (_) => setState(() => itemCtrl.toggleSelection(item.id)),
                        )
                      : _buildItemLeading(item.imagePath),
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
                    if (itemCtrl.selectionMode) {
                      setState(() => itemCtrl.toggleSelection(item.id));
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemEditPage(
                          controller: itemCtrl,
                          supplierController: widget.supplierController,
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
      bottomNavigationBar: itemCtrl.selectionMode
          ? BottomAppBar(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (itemCtrl.selectedIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No items selected")),
                          );
                          return;
                        }
                        final selectedItems = itemCtrl.items.where((it) => itemCtrl.selectedIds.contains(it.id)).toList();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BulkUpdatePage(items: selectedItems, itemController: itemCtrl),
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
                        if (itemCtrl.selectedIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No items selected")),
                          );
                          return;
                        }

                        final selectedItems = itemCtrl.items.where((it) => itemCtrl.selectedIds.contains(it.id)).toList();

                        // Add selected items into SellController with qty = 1
                        for (final item in selectedItems) {
                          sellCtrl.setQuantity(item.id, 1);
                        }

                        // Clear selection mode
                        setState(() {
                          itemCtrl.toggleSelectionMode();
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Items added to cart. Go to Sell tab.")),
                        );
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text("Add to Sell"),
                    ),
                  ),
                ],
              ),
            )
          : null,
      floatingActionButton: !itemCtrl.selectionMode
          ? FloatingAddBtn(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemAddPage(controller: itemCtrl, supplierController: widget.supplierController),
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
