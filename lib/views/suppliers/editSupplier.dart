import 'package:easyinventory/views/widgets/app_bar.global.dart';
import 'package:easyinventory/views/widgets/text_form.global.dart';
import 'package:flutter/material.dart';
import 'package:easyinventory/controllers/supplier.controller.dart';

class EditSupplierPage extends StatefulWidget {
  const EditSupplierPage({super.key, required this.supplier});

  final String supplier;

  @override
  State<EditSupplierPage> createState() => _EditSupplierPageState();
}

class _EditSupplierPageState extends State<EditSupplierPage> {
  late TextEditingController supplierNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController emailAddressController;
  late TextEditingController addressController;

  final _formKey = GlobalKey<FormState>();
  final SupplierController _controller = SupplierController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    supplierNameController = TextEditingController(text: widget.supplier);
    phoneNumberController = TextEditingController();
    emailAddressController = TextEditingController();
    addressController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    supplierNameController.dispose();
    phoneNumberController.dispose();
    emailAddressController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: "Edit Supplier",
        rightIconBtn: Icons.check,
        onRightButtonPressed: () {
          if (_formKey.currentState!.validate()) {
            print("Supplier: ${supplierNameController.text}");
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView( // 👈 whole page scrollable
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Supplier Name
                Text("Supplier's Name", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                TextForm(
                  controller: supplierNameController,
                  text: "Supplier's Name",
                  textInputType: TextInputType.name,
                  mustFill: true,
                  errorMessage: "Supplier's name is required",
                ),
                SizedBox(height: 16),

                // Phone
                Text("Phone", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                TextForm(
                  controller: phoneNumberController,
                  text: "Phone Number",
                  textInputType: TextInputType.phone,
                ),
                SizedBox(height: 16),

                // Email
                Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                TextForm(
                  controller: emailAddressController,
                  text: "Email Address",
                  textInputType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),

                // Address
                Text("Address", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                TextForm(
                  controller: addressController,
                  text: "Address",
                  textInputType: TextInputType.text,
                ),
                SizedBox(height: 16),

                // Items section
                Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Divider(),

                // Instead of ListView, just loop with Column
                Column(
                  children: List.generate(_controller.items.length, (index) {
                    final item = _controller.items[index];
                    return ListTile(
                      leading: item["imagePath"] != null
                          ? Image.asset(
                              item["imagePath"]!,
                              width: 40,
                              height: 40,
                              errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported),
                            )
                          : Icon(Icons.image),
                      title: Text(item["name"] ?? "Unnamed"),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
