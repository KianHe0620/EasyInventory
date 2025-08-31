import 'package:easyinventory/view/widgets/appBar.global.dart';
import 'package:easyinventory/view/widgets/textForm.global.dart';
import 'package:flutter/material.dart';

class AddSupplierPage extends StatefulWidget {
  const AddSupplierPage({super.key});

  @override
  State<AddSupplierPage> createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  final TextEditingController supplierNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(   // 👈 put it here
        title: "Add Supplier",
        rightIconBtn: Icons.check,
        onRightButtonPressed: () {
          if(_formKey.currentState!.validate()){
            // Confirm Adding Supplier
            print("Supplier: ${supplierNameController.text}");
          }
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                //Supplier Name
                Text(
                  "Supplier's Name",
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 5,),
                TextForm(
                  controller: supplierNameController,
                  text: "Supplier's Name",
                  textInputType: TextInputType.name,
                  mustFill: true,
                  errorMessage: "Supplier's name is required",
                ),
                SizedBox(height: 16,),

                //Phone Number
                Text(
                  "Phone",
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 5,),
                TextForm(
                  controller: phoneNumberController,
                  text: "Phone Number",
                  textInputType: TextInputType.phone,
                ),
                SizedBox(height: 16,),

                //Email Address
                Text(
                  "Email",
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 5,),
                TextForm(
                  controller: emailAddressController,
                  text: "Email Address",
                  textInputType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16,),

                //Address
                Text(
                  "Address",
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 5,),
                TextForm(
                  controller: addressController,
                  text: "Address",
                  textInputType: TextInputType.text,
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}
