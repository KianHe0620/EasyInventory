import 'package:flutter/material.dart';
import 'package:easyinventory/utils/global.colors.dart';

class TextForm extends StatelessWidget {
  const TextForm({super.key, required this.controller, required this.text, required this.textInputType, required this.obscure});
  final TextEditingController controller;
  final String text;
  final TextInputType textInputType;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GlobalColors.TextFieldColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: textInputType,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: text,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}