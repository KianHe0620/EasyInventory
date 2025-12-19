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
      Navigator.pop(context, newSupplier);
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
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextForm(
                  controller: supplierNameController,
                  text: "Supplier's Name",
                  textInputType: TextInputType.text,
                  mustFill: true,
                  errorMessage: "Supplier name is required",
                ),
                TextForm(
                  controller: phoneNumberController,
                  text: "Phone Number",
                  textInputType: TextInputType.phone,
                ),
                TextForm(
                  controller: emailAddressController,
                  text: "Email Address",
                  textInputType: TextInputType.emailAddress,
                ),
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
