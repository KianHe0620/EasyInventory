import 'package:flutter/material.dart';
import 'package:easyinventory/views/utils/global.colors.dart';

class TextForm extends StatelessWidget {
  const TextForm({
    super.key, 
    required this.controller, 
    required this.text, 
    required this.textInputType, 
    this.obscure = false, 
    this.mustFill = false,
    this.errorMessage = "Please fill in this field"
  });
  final TextEditingController controller;
  final String text;
  final TextInputType textInputType;
  final bool obscure;
  final bool mustFill;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        controller: controller,
        keyboardType: textInputType,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: text,
          hintStyle: TextStyle(fontWeight: FontWeight.w400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none
          ),
          filled: true,
          fillColor: GlobalColors.textFieldColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        validator: mustFill
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return errorMessage;
              }
              return null;
            }
          : null,
      ),
    );
  }
}