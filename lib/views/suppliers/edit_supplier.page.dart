import 'package:flutter/material.dart';
import 'package:easyinventory/views/widgets/app_bar.global.dart';
import 'package:easyinventory/views/widgets/text_form.global.dart';
import 'package:easyinventory/controllers/supplier.controller.dart';
import 'package:easyinventory/models/supplier.model.dart';
import 'package:get/get.dart';

class EditSupplierPage extends StatefulWidget {
  final SupplierController supplierController = Get.find<SupplierController>();
  final Supplier supplier;

  EditSupplierPage({
    super.key,
    required this.supplier,
  });

  @override
  State<EditSupplierPage> createState() => _EditSupplierPageState();
}

class _EditSupplierPageState extends State<EditSupplierPage> {
  late TextEditingController supplierNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController emailAddressController;
  late TextEditingController addressController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    supplierNameController = TextEditingController(text: widget.supplier.name);
    phoneNumberController = TextEditingController(text: widget.supplier.phone);
    emailAddressController = TextEditingController(text: widget.supplier.email);
    addressController = TextEditingController(text: widget.supplier.address);
  }

  @override
  void dispose() {
    supplierNameController.dispose();
    phoneNumberController.dispose();
    emailAddressController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _saveSupplier() {
    if (_formKey.currentState!.validate()) {
      final updated = widget.supplier.copyWith(
        name: supplierNameController.text.trim(),
        phone: phoneNumberController.text.trim(),
        email: emailAddressController.text.trim(),
        address: addressController.text.trim(),
      );

      widget.supplierController.updateSupplier(widget.supplier.id, updated);

      Get.back(result: updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: "Edit Supplier",
        rightIconBtn: Icons.check,
        onRightButtonPressed: _saveSupplier,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                const Text("Supplier's Name", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                TextForm(
                  controller: supplierNameController,
                  text: "Supplier's Name",
                  textInputType: TextInputType.name,
                  mustFill: true,
                  errorMessage: "Supplier's name is required",
                ),
                const SizedBox(height: 16),

                const Text("Phone", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                TextForm(
                  controller: phoneNumberController,
                  text: "Phone Number",
                  textInputType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                TextForm(
                  controller: emailAddressController,
                  text: "Email Address",
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                const Text("Address", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                TextForm(
                  controller: addressController,
                  text: "Address",
                  textInputType: TextInputType.text,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
