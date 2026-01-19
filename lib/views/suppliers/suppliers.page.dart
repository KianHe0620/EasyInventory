import 'package:easyinventory/models/item.model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/item.controller.dart';
import '../../controllers/supplier.controller.dart';
import '../../views/suppliers/add_supplier.page.dart';
import '../../views/suppliers/edit_supplier.page.dart';
import '../../views/widgets/floating_add_btn.global.dart';
import '../../views/widgets/search.global.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final SupplierController _controller = SupplierController();
  final ItemController _itemController = Get.find<ItemController>();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  // -------------------------------
  // Group items by supplier
  // -------------------------------
  Map<String, List<Item>> _itemsBySupplier() {
    final map = <String, List<Item>>{};
    final fallback = _itemController.fallbackSupplier;

    for (final item in _itemController.items) {
      final key = item.supplier.isNotEmpty ? item.supplier : fallback;
      map.putIfAbsent(key, () => []);
      map[key]!.add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final itemsBySupplier = _itemsBySupplier();
    final fallbackSupplier = _itemController.fallbackSupplier;

    final uncategorizedItems =
        itemsBySupplier[fallbackSupplier] ?? [];
    final showUncategorized = uncategorizedItems.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _controller.isSelectionMode
            ? Text('${_controller.selectedSuppliers.length} selected')
            : const Text('Suppliers'),
        actions: [
          IconButton(
            icon: Icon(
              _controller.isSelectionMode ? Icons.close : Icons.checklist,
            ),
            onPressed: () {
              _controller.toggleSelectionMode();
            },
          ),

          if (_controller.isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _controller.selectedSuppliers.isEmpty
                  ? null
                  : () async {
                      final confirm = await Get.dialog<bool>(
                        AlertDialog(
                          title: const Text("Delete Suppliers"),
                          content: Text(
                            "Delete ${_controller.selectedSuppliers.length} supplier(s)?\n"
                            "Items using them will be set to Uncategorized.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Get.back(result: true),
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.white),
                                ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _controller.removeSelectedSuppliers();

                        // normalize items → Uncategorized
                        final existingSupplierNames =
                            _controller.allSuppliers.map((s) => s.name).toSet();

                        _itemController
                            .normalizeInvalidSuppliers(existingSupplierNames);

                        _controller.toggleSelectionMode();
                      }
                    },
            ),
        ],
      ),
      floatingActionButton: FloatingAddBtn(
        onPressed: () {Get.to(()=>AddSupplierPage());},
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SearchBarGlobal(
              controller: _controller.searchController,
              onChanged: _controller.filterSuppliers,
              onClear: _controller.clearSearch,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 0, thickness: 0.8),

          Expanded(
            child: ListView.separated(
              itemCount: _controller.filteredSuppliers.length + (showUncategorized ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {

                //UNCATEGORIZED SUPPLIER
                if (showUncategorized && index == 0) {
                  return ListTile(
                    title: Text(
                      fallbackSupplier,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Needs attention · ${uncategorizedItems.length} item(s)',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          uncategorizedItems
                                  .take(3)
                                  .map((e) => e.name)
                                  .join(', ') +
                              (uncategorizedItems.length > 3 ? ' …' : ''),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // NORMAL SUPPLIERS
                final realIndex =
                    showUncategorized ? index - 1 : index;
                final supplier =
                    _controller.filteredSuppliers[realIndex];
                final isSelected =
                    _controller.isSelected(supplier.id);

                return ListTile(
                  title: Text(supplier.name),
                  trailing: _controller.isSelectionMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (_) =>
                              _controller.toggleSelection(supplier.id),
                        )
                      : null,
                  onTap: () {
                    if (_controller.isSelectionMode) {
                      _controller.toggleSelection(supplier.id);
                    } else {
                      Get.to(() =>EditSupplierPage(supplier: supplier));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
