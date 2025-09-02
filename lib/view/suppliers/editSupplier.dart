import 'package:easyinventory/view/widgets/appBar.global.dart';
import 'package:easyinventory/view/widgets/textForm.global.dart';
import 'package:flutter/material.dart';

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
      appBar: GlobalAppBar(   // 👈 put it here
        title: "Edit Supplier",
        rightIconBtn: Icons.check,
        onRightButtonPressed: () {
          if(_formKey.currentState!.validate()){
            // Confirm Editting Supplier
            print("Supplier: ${supplierNameController.text}");
          }
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
                    SizedBox(height: 8,),
                    Text(
                      "Items:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              )
            ),
            SizedBox(height: 8,),
            Divider(),
            Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 1,
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.8),
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(""),
                    onTap: () {
                      // Navigator.push(
                      //   context, 
                      //   MaterialPageRoute(
                      //     builder: (_) => 
                      //   )
                      // );
                    },
                  ),
                );
              },
            ),
          ),
          ]
        )
      ),
    );
  }
}
