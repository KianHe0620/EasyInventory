// lib/views/items/item_edit.page.dart
import 'dart:io';
import 'package:easyinventory/views/utils/barcode_scanner.utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
  String? supplierId;
  String field = "Uncategorized";

  // We still keep a local picked file for immediate user preview when user picks from camera/gallery.
  // But the canonical preview path is provided by controller.getEffectiveImagePath(itemId).
  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    nameCtrl = TextEditingController(text: item?.name ?? "");
    purchaseCtrl = TextEditingController(text: item != null ? item.purchasePrice.toStringAsFixed(2) : "");
    sellingCtrl = TextEditingController(text: item != null ? item.sellingPrice.toStringAsFixed(2) : "");
    barcodeCtrl = TextEditingController(text: item?.barcode ?? "");
    quantity = item?.quantity ?? 0;
    minQuantity = item?.minQuantity ?? 0;

    // set supplierId by matching supplier name
    if (item != null && item.supplier.isNotEmpty) {
      final matches = widget.supplierController.filteredSuppliers.where((s) => s.name == item.supplier);
      if (matches.isNotEmpty) {
        supplierId = matches.first.id;
      } else if (widget.supplierController.filteredSuppliers.isNotEmpty) {
        supplierId = widget.supplierController.filteredSuppliers.first.id;
      } else {
        supplierId = null;
      }
    } else {
      supplierId = widget.supplierController.filteredSuppliers.isNotEmpty ? widget.supplierController.filteredSuppliers.first.id : null;
    }

    final fields = widget.controller.getFields();
    if (item != null && item.field.isNotEmpty && fields.contains(item.field)) {
      field = item.field;
    } else {
      field = fields.isNotEmpty ? fields.first : 'Uncategorized';
    }

    // Listen to controller so we can refresh preview when editingImagePaths change
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    purchaseCtrl.dispose();
    sellingCtrl.dispose();
    barcodeCtrl.dispose();
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {
      // rebuild preview using controller.getEffectiveImagePath(...)
    });
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

  // PICK IMAGE (no crop). This sets _pickedImageFile and also informs controller of temp path.
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) {
        // user canceled
        return;
      }

      setState(() {
        _pickedImageFile = File(picked.path);
      });

      // notify controller about the temp editing path so other parts of UI see it
      if (widget.item != null) {
        widget.controller.setEditingImagePath(widget.item!.id, _pickedImageFile!.path);
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error accessing images: ${e.message}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image error: $e')));
      }
    }
  }

  Future<void> _removeImage() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove photo'),
        content: const Text('Remove the selected photo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
        ],
      ),
    );
    if (ok == true) {
      // Clear local picked file and set editing path in controller to null (indicates "no image")
      setState(() {
        _pickedImageFile = null;
      });
      if (widget.item != null) {
        widget.controller.setEditingImagePath(widget.item!.id, null);
      }
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

  // helper to render decoration image using controller effective path
  DecorationImage? _buildDecorationImage() {
    final id = widget.item?.id;
    if (id == null) return null;
    final effective = widget.controller.getEffectiveImagePath(id);
    if (effective == null || effective.isEmpty) return null;

    final file = File(effective);
    if (file.existsSync()) {
      return DecorationImage(image: FileImage(file), fit: BoxFit.cover);
    }
    // If file not found on disk, still return null to show placeholder
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final availableFields = widget.controller.getFields().toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final previewImage = _buildDecorationImage();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(widget.item == null ? "Add Item" : "Edit Item", style: const TextStyle(color: Colors.black)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: () async {
              if (widget.index == null || widget.item == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: No item selected for update")));
                return;
              }
              final selectedSupplier = widget.supplierController.getSupplierById(supplierId ?? "");
              // get effective image path from controller (could be null => store empty string)
              final effectivePath = widget.controller.getEffectiveImagePath(widget.item!.id) ?? '';

              final updatedItem = Item(
                id: widget.item!.id,
                name: nameCtrl.text.trim(),
                quantity: quantity,
                minQuantity: minQuantity,
                purchasePrice: double.tryParse(purchaseCtrl.text) ?? 0,
                sellingPrice: double.tryParse(sellingCtrl.text) ?? 0,
                barcode: barcodeCtrl.text.trim(),
                supplier: selectedSupplier?.name ?? "",
                field: field,
                imagePath: effectivePath,
              );

              await controller.updateItem(widget.index!, updatedItem);
              // clear temporary editing image for this item after persisting
              controller.clearEditingImagePath(widget.item!.id);
              Navigator.pop(context, updatedItem);
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Image (tap to change) with remove overlay
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
                    child: (previewImage == null) ? const Center(child: Icon(Icons.image, size: 80)) : null,
                  ),
                ),
                // show delete overlay only if we have an effective image (either local picked or saved)
                if ((widget.item != null && widget.controller.getEffectiveImagePath(widget.item!.id)?.isNotEmpty == true))
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
              value: supplierId,
              items: widget.supplierController.filteredSuppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
              onChanged: (val) => setState(() => supplierId = val),
              decoration: inputDecoration(),
            ),
            const SizedBox(height: 16),

            // Field dropdown
            sectionLabel("Field"),
            DropdownButtonFormField<String>(
              value: field,
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
