import 'package:flutter/material.dart';
import 'package:easyinventory/controllers/supplier.controller.dart';
import 'package:easyinventory/views/suppliers/add_supplier.page.dart';
import 'package:easyinventory/views/suppliers/edit_supplier.page.dart';
import 'package:easyinventory/views/widgets/app_bar.global.dart';
import 'package:easyinventory/views/widgets/floating_add_btn.global.dart';
import 'package:easyinventory/views/widgets/search.global.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final SupplierController _controller = SupplierController();

  @override
  void initState() {
    super.initState();
    // listen to controller so page updates when controller changes (add/remove/update)
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: _controller.isSelectionMode
            ? "${_controller.selectedSuppliers.length} selected"
            : "Suppliers",
        rightIconBtn:
            _controller.isSelectionMode ? Icons.delete : Icons.checklist,
        onRightButtonPressed: () async {
          if (_controller.isSelectionMode) {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Delete Suppliers"),
                content: const Text(
                    "Are you sure you want to delete selected suppliers?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text("Delete"),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              // use controller's removeSelectedSuppliers which handles notify
              _controller.removeSelectedSuppliers();
              // UI will update via listener
            }
          } else {
            _controller.toggleSelectionMode();
            // UI updated via listener
          }
        },
      ),
      floatingActionButton: FloatingAddBtn(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddSupplierPage(),
            ),
          );
          // no need for .then -> controller notifies and listener will rebuild
        },
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SearchBarGlobal(
              controller: _controller.searchController,
              onChanged: (value) => _controller.filterSuppliers(value),
              onClear: () => _controller.clearSearch(),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 0, thickness: 0.8, color: Colors.grey),

          // ----------------------------
          // cancel bar shown when selection mode is active
          // ----------------------------
          if (_controller.isSelectionMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel selection'),
                      onPressed: () {
                        _controller.toggleSelectionMode();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.select_all),
                      label: const Text('Select all'),
                      onPressed: () {
                        // quick "select all" helper:
                        for (final s in _controller.filteredSuppliers) {
                          _controller.selectedSuppliers.add(s.id);
                        }
                        _controller.notifyListeners();
                      },
                    ),
                  ),
                ],
              ),
            ),

          // the supplier list
          Expanded(
            child: ListView.builder(
              itemCount: _controller.filteredSuppliers.length,
              itemBuilder: (context, index) {
                final supplier = _controller.filteredSuppliers[index];
                final isSelected = _controller.isSelected(supplier.id);

                return ListTile(
                  title: Text(supplier.name),
                  trailing: _controller.isSelectionMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (_) {
                            _controller.toggleSelection(supplier.id);
                          },
                        )
                      : null,
                  onTap: () {
                    if (_controller.isSelectionMode) {
                      _controller.toggleSelection(supplier.id);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditSupplierPage(supplier: supplier),
                        ),
                      );
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
