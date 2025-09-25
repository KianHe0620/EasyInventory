import 'package:flutter/material.dart';
import '../../controllers/item.controller.dart';
import '../../controllers/supplier.controller.dart';
import '../../models/item.model.dart';
import '../widgets/floating_add_btn.global.dart';
import 'item_add.page.dart';
import 'item_edit.page.dart';
import 'filter_sidebar.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final ItemController itemController = ItemController();
  final SupplierController supplierController = SupplierController();

  @override
  Widget build(BuildContext context) {
    final filteredItems = itemController.getFilteredSortedItems();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: itemController.selectionMode
            ? Text('${itemController.selectedIds.length} selected')
            : const Text('Items'),
        actions: [
          // ✅ Selection mode toggle
          IconButton(
            icon: Icon(itemController.selectionMode ? Icons.close : Icons.checklist),
            onPressed: () {
              setState(() {
                itemController.toggleSelectionMode();
              });
            },
            tooltip: itemController.selectionMode ? 'Exit selection' : 'Selection mode',
          ),

          // ✅ Filter sidebar
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                Scaffold.of(ctx).openEndDrawer();
              },
            ),
          ),

          // ✅ Delete when in selection mode
          if (itemController.selectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                if (itemController.selectedIds.isEmpty) {
                  setState(() => itemController.toggleSelectionMode());
                  return;
                }

                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm delete'),
                    content: Text('Delete ${itemController.selectedIds.length} item(s)?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (ok == true) {
                  setState(() {
                    itemController.deleteSelected();
                  });
                }
              },
            ),
        ],
      ),

      // ✅ Sidebar
      endDrawer: FilterSidebar(
        fields: itemController.items.map((e) => e.field).toSet().toList(),
        selectedField: itemController.activeFields.isEmpty
            ? null
            : itemController.activeFields.first,
        sortBy: itemController.sortBy,
        ascending: itemController.ascending,
        onApply: (field, sortBy, asc) {
          final f = (field == null || field == "All") ? <String>{} : {field};
          setState(() {
            itemController.applyFilter(f, sortBy!, asc);
          });
        },
        onClear: () {
          setState(() {
            itemController.resetFilters();
          });
        },
      ),

      body: Column(
        children: [
          // ✅ Search bar
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              onChanged: (v) {
                setState(() {
                  itemController.setSearchQuery(v);
                });
              },
            ),
          ),

          // ✅ Item list
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, idx) {
                final item = filteredItems[idx];
                final originalIndex = itemController.items
                    .indexWhere((it) => it.id == item.id);

                return ListTile(
                  leading: itemController.selectionMode
                      ? Checkbox(
                          value: itemController.selectedIds.contains(item.id),
                          onChanged: (_) {
                            setState(() {
                              itemController.toggleSelection(item.id);
                            });
                          },
                        )
                      : (item.imagePath.isNotEmpty
                          ? Image.asset(item.imagePath,
                              width: 40, height: 40, fit: BoxFit.cover)
                          : const Icon(Icons.image,
                              size: 40, color: Colors.grey)),
                  title: Text(item.name),
                  subtitle:
                      Text('Price: RM ${item.sellingPrice.toStringAsFixed(2)}'),
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
                    if (itemController.selectionMode) {
                      setState(() {
                        itemController.toggleSelection(item.id);
                      });
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemEditPage(
                          controller: itemController,
                          supplierController: supplierController,
                          item: item,
                          index: originalIndex,
                        ),
                      ),
                    ).then((updated) {
                      if (updated != null) {
                        setState(() {}); // refresh after edit
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingAddBtn(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemAddPage(
                controller: itemController,
                supplierController: supplierController,
              ),
            ),
          ).then((newItem) {
            if (newItem != null) {
              setState(() {}); // refresh after add
            }
          });
        },
      ),
    );
  }
}
