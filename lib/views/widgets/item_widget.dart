import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/item.model.dart';
import '../utils/decimal_formatter.utils.dart';


// ---------------- ItemTile ----------------
typedef ImageLeadingBuilder = Widget Function(String imagePath);

class ItemTile extends StatelessWidget {
  final Item item;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onToggleSelection;
  final VoidCallback onTap;
  final ImageLeadingBuilder leadingBuilder;

  const ItemTile({
    super.key,
    required this.item,
    required this.selectionMode,
    required this.selected,
    required this.onToggleSelection,
    required this.onTap,
    required this.leadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: selectionMode
          ? Checkbox(value: selected, onChanged: (_) => onToggleSelection)
          : leadingBuilder(item.imagePath),
      title: Text(item.name),
      subtitle: Text('Price: RM ${item.sellingPrice.toStringAsFixed(2)}'),
      trailing: Text(
        item.quantity.toString(),
        style: TextStyle(
          color: item.quantity <= item.minQuantity
              ? Colors.red
              : item.quantity >= item.minQuantity + 20
                  ? Colors.green
                  : Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }
}

// ---------------- SelectionBottomBar ----------------
class SelectionBottomBar extends StatelessWidget {
  final VoidCallback onUpdate;
  final VoidCallback onAddToSell;

  const SelectionBottomBar({
    super.key,
    required this.onUpdate,
    required this.onAddToSell,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black26, width: 0.6),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A84D0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text("Update Quantity", style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onAddToSell,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A84D0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text("Add to Sell", style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget sectionLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 4),
  child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
);

InputDecoration inputDecoration() => const InputDecoration(
  filled: true,
  fillColor: Color(0xFFF5F5F5),
  border: OutlineInputBorder(),
);

Widget priceField(String label, String prefix, TextEditingController ctrl, void Function(void Function()) setState) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sectionLabel(label),
      TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: inputDecoration().copyWith(prefixText: "$prefix "),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          DecimalTextInputFormatter(decimalRange: 2),
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
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text("$prefix ${value.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
      ),
    ],
  );
}
