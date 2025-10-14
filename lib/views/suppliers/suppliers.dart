import 'package:flutter/material.dart';
import 'package:easyinventory/controllers/supplier.controller.dart';
import 'package:easyinventory/views/suppliers/addSupplier.dart';
import 'package:easyinventory/views/suppliers/editSupplier.dart';
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
              setState(() => _controller.removeSuppliers());
            }
          } else {
            setState(() => _controller.toggleSelectionMode());
          }
        },
      ),
      floatingActionButton: FloatingAddBtn(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddSupplierPage(controller: _controller),
            ),
          ).then((_) => setState(() {}));
        },
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SearchBarGlobal(
              controller: _controller.searchController,
              onChanged: (value) => setState(() {
                _controller.filterSuppliers(value);
              }),
              onClear: () => setState(() {
                _controller.clearSearch();
              }),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 0, thickness: 0.8, color: Colors.grey),
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
                          onChanged: (_) => setState(() {
                            _controller.toggleSelection(supplier.id);
                          }),
                        )
                      : null,
                  onTap: () {
                    if (_controller.isSelectionMode) {
                      setState(() {
                        _controller.toggleSelection(supplier.id);
                      });
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditSupplierPage(
                            controller: _controller,
                            supplier: supplier,
                          ),
                        ),
                      ).then((_) => setState(() {}));
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
