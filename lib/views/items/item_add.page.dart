// lib/views/items/item_add.page.dart
import 'dart:io';
import 'package:easyinventory/views/utils/barcode_scanner.utils.dart';
import 'package:easyinventory/views/widgets/item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _imageFile; // holds picked image
  final ImagePicker _picker = ImagePicker();

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
    }
  }

  // pick image only (no crop)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return; // user cancelled
      setState(() {
        _imageFile = File(picked.path);
      });
    } on PlatformException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error accessing images: ${e.message}')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image error: $e')));
    }
  }

  Future<void> _removeImage() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove photo'),
        content: const Text('Remove the selected photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        _imageFile = null;
      });
    }
  }

  Future<void> _showImageOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Take photo'),
            onTap: () {
              Navigator.pop(ctx);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(ctx);
              _pickImage(ImageSource.gallery);
            },
          ),
          if (_imageFile != null)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _removeImage();
              },
            ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Cancel'),
            onTap: () => Navigator.pop(ctx),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final availableFields = widget.controller.getFields().toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    // build preview from picked image (local) — for Add page there's no saved item yet
    final DecorationImage? previewImage = (_imageFile != null)
        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
        : null;

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
                // For add, leave id empty so controller.addItem will generate the doc id.
                final newItem = Item(
                  id: '', // let controller addItem create doc id
                  name: nameCtrl.text.trim(),
                  quantity: quantity,
                  minQuantity: minQuantity,
                  purchasePrice: double.tryParse(purchaseCtrl.text) ?? 0,
                  sellingPrice: double.tryParse(sellingCtrl.text) ?? 0,
                  barcode: barcodeCtrl.text.trim(),
                  supplier: selectedSupplier?.name ?? "",
                  field: field,
                  imagePath: _imageFile?.path ?? "", // persist empty if removed
                );

                // Add item (controller will generate id if empty)
                await controller.addItem(newItem);

                // Clear local picked image to avoid retaining large files in memory
                setState(() {
                  _imageFile = null;
                });

                Navigator.pop(context, newItem);
              }
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Image placeholder (tap to pick). Overlay remove icon if photo exists.
              Stack(
                children: [
                  GestureDetector(
                    onTap: _showImageOptions,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        image: previewImage,
                      ),
                      child: _imageFile == null ? const Center(child: Icon(Icons.image, size: 80)) : null,
                    ),
                  ),
                  if (_imageFile != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: _removeImage,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.delete, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Text("Tap image to choose / take photo"),
              const SizedBox(height: 16),

              // Item Name
              sectionLabel("Item’s Name"),
              TextFormField(
                controller: nameCtrl,
                decoration: inputDecoration(),
                validator: (val) => val == null || val.isEmpty ? "Please enter item name" : null,
              ),
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
