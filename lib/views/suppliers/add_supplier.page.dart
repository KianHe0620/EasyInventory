import 'package:flutter/material.dart';
import 'package:easyinventory/views/widgets/app_bar.global.dart';
import 'package:easyinventory/views/widgets/text_form.global.dart';
import 'package:easyinventory/controllers/supplier.controller.dart';
import 'package:easyinventory/models/supplier.model.dart';
import 'package:get/get.dart';

class AddSupplierPage extends StatefulWidget {
  AddSupplierPage({super.key});

  final SupplierController supplierController = Get.find<SupplierController>();

  @override
  State<AddSupplierPage> createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  final TextEditingController supplierNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _saveSupplier() {
    if (_formKey.currentState!.validate()) {
      final newSupplier = Supplier(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: supplierNameController.text.trim(),
        phone: phoneNumberController.text.trim(),
        email: emailAddressController.text.trim(),
        address: addressController.text.trim(),
      );
      widget.supplierController.addSupplier(newSupplier);
      Get.back(result: newSupplier);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: "Add Supplier",
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
