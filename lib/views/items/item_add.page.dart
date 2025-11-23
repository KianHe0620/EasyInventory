// item_add.page.dart
import 'package:easyinventory/views/utils/barcode_scanner.utils.dart';
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
  String? supplierId;
  String field = "Uncategorized";

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    purchaseCtrl = TextEditingController(text: "0.00");
    sellingCtrl = TextEditingController(text: "0.00");
    barcodeCtrl = TextEditingController();

    supplierId = widget.supplierController.filteredSuppliers.isNotEmpty
        ? widget.supplierController.filteredSuppliers.first.id
        : null;

    final fields = widget.controller.getFields();
    field = fields.isNotEmpty ? fields.first : 'Uncategorized';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    purchaseCtrl.dispose();
    sellingCtrl.dispose();
    barcodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        barcodeCtrl.text = result;
      });
    } else {
      // user cancelled or scanner returned nothing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barcode scan cancelled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final availableFields = widget.controller.getFields().toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Add Item", style: TextStyle(color: Colors.black)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final selectedSupplier = widget.supplierController.getSupplierById(supplierId ?? "");

                final newItem = Item(
                  id: DateTime.now().toString(),
                  name: nameCtrl.text.trim(),
                  quantity: quantity,
                  minQuantity: minQuantity,
                  purchasePrice: double.tryParse(purchaseCtrl.text) ?? 0,
                  sellingPrice: double.tryParse(sellingCtrl.text) ?? 0,
                  barcode: barcodeCtrl.text.trim(),
                  supplier: selectedSupplier?.name ?? "",
                  field: field,
                );

                await controller.addItem(newItem);
                Navigator.pop(context, newItem);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Image placeholder (you can integrate upload later)
              Container(height: 150, width: double.infinity, color: Colors.grey[300], child: const Icon(Icons.image, size: 80)),
              const SizedBox(height: 16),

              // Item Name
              sectionLabel("Item’s Name"),
              TextFormField(controller: nameCtrl, decoration: inputDecoration(), validator: (val) => val == null || val.isEmpty ? "Please enter item name" : null),
              const SizedBox(height: 16),

              // Quantity + Min Qty
              Row(children: [
                Expanded(child: QuantityBox(label: "Quantity", value: quantity, onChanged: (val) => setState(() => quantity = val))),
                const SizedBox(width: 8),
                Expanded(child: QuantityBox(label: "Min Quantity Alert", value: minQuantity, onChanged: (val) => setState(() => minQuantity = val))),
              ]),
              const SizedBox(height: 16),

              // Purchase price + total
              Row(children: [
                Expanded(child: priceField("Purchase Price", "RM", purchaseCtrl, setState)),
                const SizedBox(width: 8),
                Expanded(child: readonlyBox("Total", "RM", (double.tryParse(purchaseCtrl.text) ?? 0) * quantity)),
              ]),
              const SizedBox(height: 16),

              // Selling price + total
              Row(children: [
                Expanded(child: priceField("Selling Price", "RM", sellingCtrl, setState)),
                const SizedBox(width: 8),
                Expanded(child: readonlyBox("Total", "RM", (double.tryParse(sellingCtrl.text) ?? 0) * quantity)),
              ]),
              const SizedBox(height: 16),

              // Barcode with scanner
              sectionLabel("Item’s Barcode"),
              TextFormField(
                controller: barcodeCtrl,
                decoration: inputDecoration().copyWith(
                  suffixIcon: IconButton(icon: const Icon(Icons.barcode_reader, color: Colors.red), onPressed: _scanBarcode),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) => val == null || val.isEmpty ? "Enter barcode" : null,
              ),
              const SizedBox(height: 16),

              // Supplier dropdown
              sectionLabel("Supplier"),
              DropdownButtonFormField<String>(
                value: supplierId,
                items: widget.supplierController.filteredSuppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (val) => setState(() => supplierId = val),
                decoration: inputDecoration(),
                validator: (val) => val == null || val.isEmpty ? "Please select supplier" : null,
              ),
              const SizedBox(height: 16),

              // Field dropdown
              sectionLabel("Field"),
              DropdownButtonFormField<String>(
                value: field,
                items: availableFields.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (val) => setState(() => field = val ?? 'Uncategorized'),
                decoration: inputDecoration(),
                validator: (val) => val == null || val.isEmpty ? "Please select field" : null,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
