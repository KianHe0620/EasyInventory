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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.6),
        ),
      ),
      child: Row(
        children: [
          // Sorting dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSort,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: "Quantity", child: Text("Quantity")),
                    DropdownMenuItem(value: "Name", child: Text("Name")),
                    DropdownMenuItem(
                        value: "Price", child: Text("Price")),
                  ],
                  onChanged: onSortChanged,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Filter button
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onFilterPressed,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.filter_list, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
