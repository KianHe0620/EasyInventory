import 'dart:io';
import 'package:easyinventory/views/utils/barcode_scanner.utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/item.controller.dart';
import '../../controllers/supplier.controller.dart';
import '../../models/item.model.dart';
import '../widgets/quantity_box.global.dart';
import '../widgets/item_widget.dart';

class ItemEditPage extends StatefulWidget {
  final ItemController itemController = Get.find<ItemController>();
  final SupplierController supplierController = Get.find<SupplierController>();
  final Item item;
  final int index;

  ItemEditPage({
    super.key,
    required this.item,
    required this.index,
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
  String supplier = 'Uncategorized';
  String field = "Uncategorized";

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    nameCtrl = TextEditingController(text: item.name);
    purchaseCtrl = TextEditingController(text: item.purchasePrice.toStringAsFixed(2));
    sellingCtrl = TextEditingController(text: item.sellingPrice.toStringAsFixed(2));
    barcodeCtrl = TextEditingController(text: item.barcode);
    quantity = item.quantity;
    minQuantity = item.minQuantity;

    supplier = item.supplier.isNotEmpty
        ? item.supplier
        : widget.itemController.fallbackSupplier;

    final fields = widget.itemController.getFields();
    field = fields.contains(item.field)
        ? item.field
        : widget.itemController.fallbackField;
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
    final result = await Get.to(() => const BarcodeScannerPage());

    if (result != null && result.isNotEmpty) {
      setState(() {
        barcodeCtrl.text = result;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked =
        await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    widget.itemController
        .setEditingImagePath(widget.item.id, picked.path);

    setState(() {}); // 🔥 force rebuild
  }


  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take photo'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
            if (widget.itemController
                    .getEffectiveImagePath(widget.item.id)
                    ?.isNotEmpty ==
                true)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeImage() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove photo'),
        content: const Text('Remove the selected photo?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Remove')),
        ],
      ),
    );

    if (ok == true) {
      widget.itemController.setEditingImagePath(widget.item.id, null);

      setState(() {});
    }
  }


  DecorationImage? _previewImage() {
    final path = widget.itemController.getEffectiveImagePath(widget.item.id);
    if (path == null || path.isEmpty) return null;

    final file = File(path);
    if (!file.existsSync()) return null;

    return DecorationImage(image: FileImage(file), fit: BoxFit.cover);
  }

  Future<void> _saveItem() async {
    final effectivePath =
        widget.itemController.getEffectiveImagePath(widget.item.id) ?? '';

    final updatedItem = widget.item.copyWith(
      name: nameCtrl.text.trim(),
      quantity: quantity,
      minQuantity: minQuantity,
      purchasePrice: double.tryParse(purchaseCtrl.text) ?? 0,
      sellingPrice: double.tryParse(sellingCtrl.text) ?? 0,
      barcode: barcodeCtrl.text.trim(),
      supplier: supplier,
      field: field,
      imagePath: effectivePath,
    );

    await widget.itemController.updateItem(widget.index, updatedItem);
    widget.itemController.clearEditingImagePath(widget.item.id);

    Get.back(result: updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    final availableFields = widget.itemController.getFields().toList()..sort();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Edit Item"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: _saveItem
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: _showImageOptions,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      image: _previewImage(),
                    ),
                    child: _previewImage() == null
                        ? const Center(child: Icon(Icons.image, size: 80))
                        : null,
                  ),
                ),
                if (widget.itemController
                        .getEffectiveImagePath(widget.item.id)
                        ?.isNotEmpty ==
                    true)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: _removeImage,
                      child: const CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: Icon(Icons.delete, color: Colors.white),
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
            TextField(controller: nameCtrl, decoration: inputDecoration()),
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
                suffixIcon: IconButton(
                  icon: const Icon(Icons.barcode_reader), 
                  onPressed: _scanBarcode
                )
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            // Supplier dropdown
            sectionLabel("Supplier"),
            DropdownButtonFormField<String>(
              initialValue: supplier,
              items: [
                DropdownMenuItem(
                  value: widget.itemController.fallbackSupplier,
                  child: const Text("Uncategorized"),
                ),
                ...widget.supplierController.filteredSuppliers.map(
                  (s) => DropdownMenuItem(
                    value: s.name,   // 🔥 USE NAME
                    child: Text(s.name),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  supplier = val!;
                });
              },
              decoration: inputDecoration(),
            ),
            const SizedBox(height: 16),

            // Field dropdown
            sectionLabel("Field"),
            DropdownButtonFormField<String>(
              initialValue: field,
              items: availableFields.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (val) => setState(() => field = val ?? 'Uncategorized'),
              decoration: inputDecoration(),
            ),
          ]),
        ),
      ),
    );
  }
}
