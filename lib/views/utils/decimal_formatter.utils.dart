import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // allow empty
    if (text.isEmpty) {
      return newValue;
    }

    // allow only valid decimal pattern: 12.34
    if (RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      // check decimal places
      if (text.contains('.')) {
        final parts = text.split('.');
        if (parts.length > 2) return oldValue; // invalid (double dot)

        if (parts[1].length > decimalRange) {
          return oldValue; // block further input
        }
      }
      return newValue;
    }

    return oldValue;
  }
}
