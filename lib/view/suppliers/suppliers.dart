import 'package:easyinventory/controller/supplier.controller.dart';
import 'package:easyinventory/view/suppliers/addSupplier.dart';
import 'package:easyinventory/view/suppliers/editSupplier.dart';
import 'package:easyinventory/view/widgets/appBar.global.dart';
import 'package:easyinventory/view/widgets/floatingAddBtn.global.dart';
import 'package:easyinventory/view/widgets/search.global.dart';
import 'package:flutter/material.dart';

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
      appBar: GlobalAppBar(   // 👈 moved here
        title: "Suppliers",
        rightIconBtn: Icons.checklist,
        onRightButtonPressed: () {
          // Manage Bulk
        },
      ),
      floatingActionButton: FloatingAddBtn(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddSupplierPage()),
          );
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SearchBarGlobal(
              controller: _controller.searchController,
              onChanged: (value) {
                setState(() {
                  _controller.filterSuppliers(value);
                });
              },
              onClear: () {
                setState(() {
                  _controller.clearSearch();
                });
              },
            ),
          ),

          const SizedBox(height: 16),
          const Divider(
            height: 0,
            thickness: 0.8,
            color: Colors.grey,
          ),

          // Supplier List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _controller.filteredSuppliers.length,
              itemBuilder: (context, index) {
                final supplier = _controller.filteredSuppliers[index];
                return Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.8),
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(supplier),
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => EditSupplierPage(supplier: supplier)
                        )
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
