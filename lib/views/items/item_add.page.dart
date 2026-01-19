import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/item.controller.dart';
import '../../controllers/supplier.controller.dart';
import '../../models/item.model.dart';
import '../utils/barcode_scanner.utils.dart';
import '../widgets/item_widget.dart';
import '../widgets/quantity_box.global.dart';

class ItemAddPage extends StatefulWidget {
  final ItemController itemController = Get.find<ItemController>();
  final SupplierController supplierController = Get.find<SupplierController>();

  ItemAddPage({super.key});

  @override
  State<ItemAddPage> createState() => _ItemAddPageState();
}

class _ItemAddPageState extends State<ItemAddPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameCtrl;
  late final TextEditingController purchaseCtrl;
  late final TextEditingController sellingCtrl;
  late final TextEditingController barcodeCtrl;

  int quantity = 0;
  int minQuantity = 0;

  String supplier = "Uncategorized";
  String field = "Uncategorized";

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    nameCtrl = TextEditingController();
    purchaseCtrl = TextEditingController(text: "0.00");
    sellingCtrl = TextEditingController(text: "0.00");
    barcodeCtrl = TextEditingController();

    // Default supplier & field
    supplier = widget.itemController.fallbackSupplier;

    final fields = widget.itemController.getFields();
    field = fields.isNotEmpty ? fields.first : widget.itemController.fallbackField;
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
      barcodeCtrl.text = result;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked =
        await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
    });
  }

  Future<void> _removeImage() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove photo'),
        content: const Text('Remove the selected photo?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result:true), child: const Text('Remove')),
        ],
      ),
    );

    if (ok == true) {
      setState(() => _imageFile = null);
    }
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
            if (_imageFile != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
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

  @override
  Widget build(BuildContext context) {
    final availableFields =
        widget.itemController.getFields().toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final DecorationImage? previewImage =
        _imageFile != null
            ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
            : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Add Item", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: _saveItem,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Image
              Stack(
                children: [
                  GestureDetector(
                    onTap: _showImageOptions,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        image: previewImage,
                      ),
                      child: previewImage == null
                          ? const Center(child: Icon(Icons.image, size: 80))
                          : null,
                    ),
                  ),
                  if (_imageFile != null)
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

              const SizedBox(height: 16),

              sectionLabel("Item’s Name"),
              TextFormField(
                controller: nameCtrl,
                decoration: inputDecoration(),
                validator: (v) => v == null || v.isEmpty ? "Please enter item name" : null,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: QuantityBox(label: "Quantity", value: quantity, onChanged: (v) => setState(() => quantity = v))),
                  const SizedBox(width: 8),
                  Expanded(child: QuantityBox(label: "Min Quantity Alert", value: minQuantity, onChanged: (v) => setState(() => minQuantity = v))),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: priceField("Purchase Price", "RM", purchaseCtrl, setState)),
                  const SizedBox(width: 8),
                  Expanded(child: readonlyBox("Total", "RM", (double.tryParse(purchaseCtrl.text) ?? 0) * quantity)),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: priceField("Selling Price", "RM", sellingCtrl, setState)),
                  const SizedBox(width: 8),
                  Expanded(child: readonlyBox("Total", "RM", (double.tryParse(sellingCtrl.text) ?? 0) * quantity)),
                ],
              ),

              const SizedBox(height: 16),

              sectionLabel("Item’s Barcode"),
              TextFormField(
                controller: barcodeCtrl,
                decoration: inputDecoration().copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.barcode_reader),
                    onPressed: _scanBarcode,
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              const SizedBox(height: 16),

              sectionLabel("Supplier"),
              DropdownButtonFormField<String>(
                initialValue: supplier,
                items: [
                  DropdownMenuItem(
                    value: widget.itemController.fallbackSupplier,
                    child: const Text("Uncategorized"),
                  ),
                  ...widget.supplierController.filteredSuppliers.map(
                    (s) => DropdownMenuItem(value: s.name, child: Text(s.name)),
                  ),
                ],
                onChanged: (v) => setState(() => supplier = v!),
                decoration: inputDecoration(),
              ),

              const SizedBox(height: 16),

              sectionLabel("Field"),
              DropdownButtonFormField<String>(
                initialValue: field,
                items: availableFields
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => field = v ?? widget.itemController.fallbackField),
                decoration: inputDecoration(),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final newItem = Item(
      id: '',
      name: nameCtrl.text.trim(),
      quantity: quantity,
      minQuantity: minQuantity,
      purchasePrice: double.tryParse(purchaseCtrl.text) ?? 0,
      sellingPrice: double.tryParse(sellingCtrl.text) ?? 0,
      barcode: barcodeCtrl.text.trim(),
      supplier: supplier,
      field: field,
      imagePath: _imageFile?.path ?? '',
    );

    await widget.itemController.addItem(newItem);
    Get.back(result:newItem);
  }
}
