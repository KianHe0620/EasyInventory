import 'package:flutter/material.dart';
import '../../controllers/item.controller.dart';
import '../../controllers/supplier.controller.dart';
import '../../models/item.model.dart';
import '../widgets/quantity_box.global.dart';
import '../widgets/item_widget.dart';

class ItemEditPage extends StatefulWidget {
  final ItemController controller;
  final SupplierController supplierController;
  final Item? item;
  final int? index;

  const ItemEditPage({
    super.key,
    required this.controller,
    required this.supplierController,
    this.item,
    this.index,
  });

  @override
  State<ItemEditPage> createState() => _ItemEditPageState();
}

class _ItemEditPageState extends State<ItemEditPage> {
  late TextEditingController nameCtrl;
  late TextEditingController purchaseCtrl;
  late TextEditingController sellingCtrl;
  late TextEditingController barcodeCtrl;

  int quantity = 0;
  int minQuantity = 0;
  String? supplier;
  String field = "Food";

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    nameCtrl = TextEditingController(text: item?.name ?? "");
    purchaseCtrl = TextEditingController(
        text: item?.purchasePrice != null ? item!.purchasePrice.toString() : "");
    sellingCtrl = TextEditingController(
        text: item?.sellingPrice != null ? item!.sellingPrice.toString() : "");
    barcodeCtrl = TextEditingController(text: item?.barcode ?? "");
    quantity = item?.quantity ?? 0;
    minQuantity = item?.minQuantity ?? 0;

    supplier = item?.supplier.isNotEmpty == true
        ? item!.supplier
        : widget.supplierController.filteredSuppliers.first;
    field = item?.field.isNotEmpty == true ? item!.field : "Food";
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.item == null ? "Add Item" : "Edit Item",
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: () {
              if (widget.index == null || widget.item == null) {
                // Prevent null crash
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error: No item selected for update")),
                );
                return;
              }

              final updatedItem = Item(
                id: widget.item!.id, // keep the same ID for consistency
                name: nameCtrl.text,
                quantity: quantity,
                minQuantity: minQuantity,
                purchasePrice: double.tryParse(purchaseCtrl.text) ?? 0,
                sellingPrice: double.tryParse(sellingCtrl.text) ?? 0,
                barcode: barcodeCtrl.text,
                supplier: supplier ?? "",
                field: field,
              );

              controller.updateItem(widget.index!, updatedItem);

              Navigator.pop(context, updatedItem); // ✅ return updated item
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📷 Image section
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 80),
              ),
              const SizedBox(height: 16),

              // Item Name
              sectionLabel("Item’s Name"),
              TextField(
                controller: nameCtrl,
                decoration: inputDecoration(),
              ),
              const SizedBox(height: 16),

              // Quantity + Min Qty
              Row(
                children: [
                  Expanded(
                    child: QuantityBox(
                      label: "Quantity",
                      value: quantity,
                      onChanged: (val) => setState(() => quantity = val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: QuantityBox(
                      label: "Min Quantity Alert",
                      value: minQuantity,
                      onChanged: (val) => setState(() => minQuantity = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Purchase price + total
              Row(
                children: [
                  Expanded(
                    child: priceField("Purchase Price", "RM", purchaseCtrl, setState),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: readonlyBox(
                      "Total",
                      "RM",
                      (double.tryParse(purchaseCtrl.text) ?? 0) * quantity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Selling price + total
              Row(
                children: [
                  Expanded(
                    child: priceField("Selling Price", "RM", sellingCtrl, setState),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: readonlyBox(
                      "Total",
                      "RM",
                      (double.tryParse(sellingCtrl.text) ?? 0) * quantity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Barcode
              sectionLabel("Item’s Barcode"),
              TextField(
                controller: barcodeCtrl,
                decoration: inputDecoration().copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.barcode_reader, color: Colors.red),
                    onPressed: () {
                      // TODO: implement barcode scanning logic here
                    },
                  )
                ),
              ),
              const SizedBox(height: 16),

              // Supplier dropdown
              sectionLabel("Supplier"),
              DropdownButtonFormField<String>(
                value: supplier,
                items: widget.supplierController.filteredSuppliers
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => supplier = val),
                decoration: inputDecoration(),
              ),
              const SizedBox(height: 16),

              // Field dropdown
              sectionLabel("Field"),
              DropdownButtonFormField<String>(
                value: field,
                items: const [
                  DropdownMenuItem(value: "Food", child: Text("Food")),
                  DropdownMenuItem(value: "Beverage", child: Text("Beverage")),
                  DropdownMenuItem(value: "Pet", child: Text("Pet")),
                ],
                onChanged: (val) => setState(() => field = val ?? "Food"),
                decoration: inputDecoration(),
              ),
            ],
          ),
        ),
      )
    );
  }
}
