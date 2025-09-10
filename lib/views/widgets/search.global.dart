import 'package:easyinventory/views/utils/global.colors.dart';
import 'package:flutter/material.dart';

class SearchBarGlobal extends StatelessWidget {
  const SearchBarGlobal({super.key, required this.controller, required this.onChanged, required this.onClear});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: "Search..",
        suffixIcon: IconButton(
          onPressed: onClear, 
          icon: Icon(Icons.close,size: 20,)
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
            color: GlobalColors.textFieldColor,
            width: 2
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
            color: GlobalColors.textFieldColor,
            width: 2
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}