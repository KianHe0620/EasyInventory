import 'package:easyinventory/views/widgets/item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/item.controller.dart';
import '../../controllers/supplier.controller.dart';
import '../../models/item.model.dart';
import '../widgets/quantity_box.global.dart';

class ItemAddPage extends StatefulWidget {
  final ItemController controller;
  final SupplierController supplierController;

  const ItemAddPage({
    super.key,
    required this.controller,
    required this.supplierController,
  });

  @override
  State<ItemAddPage> createState() => _ItemAddPageState();
}

class _ItemAddPageState extends State<ItemAddPage> {
  final _formKey = GlobalKey<FormState>();

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
    nameCtrl = TextEditingController();
    purchaseCtrl = TextEditingController(text: "0.00");
    sellingCtrl = TextEditingController(text: "0.00");
    barcodeCtrl = TextEditingController();

    // default supplier = first one
    supplier = widget.supplierController.filteredSuppliers.isNotEmpty
        ? widget.supplierController.filteredSuppliers.first
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Add Item", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newItem = Item(
                  id: DateTime.now().toString(), // unique ID
                  name: nameCtrl.text,
                  quantity: quantity,
                  minQuantity: minQuantity,
                  purchasePrice: double.tryParse(purchaseCtrl.text) ?? 0,
                  sellingPrice: double.tryParse(sellingCtrl.text) ?? 0,
                  barcode: barcodeCtrl.text,
                  supplier: supplier ?? "",
                  field: field,
                );

                controller.addItem(newItem);

                Navigator.pop(context, newItem); // ✅ return new item
              }
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey, // ✅ validation form
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
                TextFormField(
                  controller: nameCtrl,
                  decoration: inputDecoration(),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Please enter item name" : null,
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
                TextFormField(
                  controller: barcodeCtrl,
                  decoration: inputDecoration().copyWith(
                    suffixIcon: const Icon(Icons.qr_code_scanner, color: Colors.red),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter barcode" : null,
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
                  validator: (val) => val == null || val.isEmpty
                      ? "Please select supplier"
                      : null,
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
                  validator: (val) => val == null || val.isEmpty
                      ? "Please select field"
                      : null,
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
