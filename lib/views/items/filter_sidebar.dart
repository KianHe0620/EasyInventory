import 'package:flutter/material.dart';

class FilterSidebar extends StatefulWidget {
  final List<String> fields; // fields from controller
  final String? selectedField; // nullable (can be "All")
  final String? sortBy;
  final bool ascending;
  final Function(String?, String?, bool) onApply;
  final VoidCallback onClear;

  const FilterSidebar({
    super.key,
    required this.fields,
    required this.selectedField,
    required this.sortBy,
    required this.ascending,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterSidebar> createState() => _FilterSidebarState();
}

class _FilterSidebarState extends State<FilterSidebar> {
  String? selectedField;
  String? selectedSort;
  late bool ascending;

  @override
  void initState() {
    super.initState();
    // default selected field = provided or "All"
    selectedField = widget.selectedField ?? "All";
    // default sort = provided or "Name"
    selectedSort = widget.sortBy ?? "Name";
    ascending = widget.ascending;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Filter & Sort",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),

            // Fields section
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Fields",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  RadioListTile<String>(
                    title: const Text("All"),
                    value: "All",
                    groupValue: selectedField,
                    onChanged: (val) => setState(() => selectedField = val),
                  ),
                  for (var field in widget.fields)
                    RadioListTile<String>(
                      title: Text(field),
                      value: field,
                      groupValue: selectedField,
                      onChanged: (val) => setState(() => selectedField = val),
                    ),
                ],
              ),
            ),

            const Divider(),

            // Sort By (fixed options: Name / Price / Quantity)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Sort By",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            RadioListTile<String>(
              title: const Text("Name"),
              value: "Name",
              groupValue: selectedSort,
              onChanged: (val) => setState(() => selectedSort = val),
            ),
            RadioListTile<String>(
              title: const Text("Price"),
              value: "Price",
              groupValue: selectedSort,
              onChanged: (val) => setState(() => selectedSort = val),
            ),
            RadioListTile<String>(
              title: const Text("Quantity"),
              value: "Quantity",
              groupValue: selectedSort,
              onChanged: (val) => setState(() => selectedSort = val),
            ),

            const Divider(),

            // Order
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Order",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            SwitchListTile(
              title: Text(ascending ? "Ascending" : "Descending"),
              value: ascending,
              onChanged: (val) => setState(() => ascending = val),
            ),

            const Spacer(),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      ),
                      onPressed: () {
                        widget.onClear();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Clear All",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(selectedField, selectedSort, ascending);
                        Navigator.pop(context);
                      },
                      child: const Text("Apply"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
