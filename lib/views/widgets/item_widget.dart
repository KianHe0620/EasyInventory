import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget sectionLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

InputDecoration inputDecoration() {
  return const InputDecoration(
    filled: true,
    fillColor: Color(0xFFF5F5F5),
    border: OutlineInputBorder(),
  );
}

Widget priceField(
    String label, 
    String prefix, 
    TextEditingController ctrl, 
    void Function(void Function()) setState) 
    {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionLabel(label),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: inputDecoration().copyWith(prefixText: "$prefix "),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?d{0,2}')),
            ],
            onChanged: (_) => setState(() {}),
          ),
        ],
      );
    }

Widget readonlyBox(String label, String prefix, double value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sectionLabel(label),
      Container(
        width: double.infinity, // ✅ expand fully
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "$prefix ${value.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    ],
  );
}

