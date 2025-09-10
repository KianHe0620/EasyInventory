import 'package:flutter/material.dart';

class SortingBar extends StatelessWidget {
  final String selectedSort;
  final ValueChanged<String?> onSortChanged;
  final VoidCallback onFilterPressed;

  const SortingBar({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: selectedSort,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: "Quantity", child: Text("Quantity")),
                DropdownMenuItem(value: "Name", child: Text("Name")),
                DropdownMenuItem(value: "Price", child: Text("Price")),
              ],
              onChanged: onSortChanged,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: onFilterPressed,
          ),
        ],
      ),
    );
  }
}
