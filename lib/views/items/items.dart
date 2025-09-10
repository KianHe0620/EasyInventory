import 'package:easyinventory/controllers/supplier.controller.dart';
import 'package:flutter/material.dart';
import 'package:easyinventory/controllers/item.controller.dart';
import 'package:easyinventory/views/widgets/sorting_bar.global.dart';
import 'package:easyinventory/views/widgets/floating_add_btn.global.dart';
import 'item_edit.page.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final ItemController _controller = ItemController();
  final SupplierController _supplierController = SupplierController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Items"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search), 
            onPressed: () {
            
          }),
          IconButton(
            icon: const Icon(Icons.sort), 
            onPressed: () {

          }),
        ],
      ),
      body: Column(
        children: [
          SortingBar(
            selectedSort: _controller.sortBy,
            onSortChanged: (value) {
              setState(() {
                _controller.sortItems(value!);
              });
            },
            onFilterPressed: () {
              setState(() {
                _controller.toggleSortOrder(); // flip ascending/descending
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _controller.items.length,
              itemBuilder: (context, index) {
                final item = _controller.items[index];
                return ListTile(
                  leading: item.imagePath.isNotEmpty
                      ? Image.asset(item.imagePath, width: 40, height: 40)
                      : const Icon(Icons.image, size: 40, color: Colors.grey),
                  title: Text(item.name),
                  subtitle: Text("Price: RM ${item.sellingPrice.toStringAsFixed(2)}"),
                  trailing: Text(
                    item.quantity.toString(),
                    style: TextStyle(
                      color: item.quantity <= 2
                          ? Colors.red
                          : item.quantity <= 5
                              ? Colors.blue
                              : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => ItemEditPage(
                          controller: _controller,
                          supplierController: _supplierController,
                          item: item,)
                      )
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ✅ Floating Add Button
      floatingActionButton: FloatingAddBtn(
        onPressed: () {
          // TODO: Navigate to add item page
          debugPrint("Add Item button pressed");
        },
      ),
    );
  }
}
