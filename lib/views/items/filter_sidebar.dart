import 'package:flutter/material.dart';

class FilterSidebar extends StatefulWidget {
  final List<String> fields;
  final String? selectedField;
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
    selectedField = widget.selectedField ?? "All";
    selectedSort = widget.sortBy ?? "Name";
    ascending = widget.ascending;
  }

  @override
  Widget build(BuildContext context) {
    final fieldOptions = ["All", ...widget.fields];

    return Drawer(
      child: SafeArea(
        child: Container(
          color: Colors.white, // ✅ WHITE background
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header =====
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Filter & Sort",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),

              // ===== Field =====
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Field",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: selectedField,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: fieldOptions
                      .map(
                        (field) => DropdownMenuItem<String>(
                          value: field,
                          child: Text(field),
                        ),
                      )
                      .toList(),
                  onChanged: (val) =>
                      setState(() => selectedField = val),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),

              // ===== Sort By =====
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Sort By",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              RadioListTile<String>(
                title: const Text("Name"),
                value: "Name",
                groupValue: selectedSort,
                onChanged: (val) =>
                    setState(() => selectedSort = val),
              ),
              RadioListTile<String>(
                title: const Text("Price"),
                value: "Price",
                groupValue: selectedSort,
                onChanged: (val) =>
                    setState(() => selectedSort = val),
              ),
              RadioListTile<String>(
                title: const Text("Quantity"),
                value: "Quantity",
                groupValue: selectedSort,
                onChanged: (val) =>
                    setState(() => selectedSort = val),
              ),

              const Divider(),

              // ===== Order =====
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Order",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              SwitchListTile(
                title:
                    Text(ascending ? "Ascending" : "Descending"),
                value: ascending,
                onChanged: (val) =>
                    setState(() => ascending = val),
              ),

              const Spacer(),

              // ===== Actions =====
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0A84D0), // text color
                          side: const BorderSide(
                            color: Color(0xFF0A84D0),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () {
                          widget.onClear();
                          Navigator.pop(context);
                        },
                        child: const Text("Clear"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A84D0),
                          foregroundColor: Colors.white, // ✅ FIX TEXT COLOR
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () {
                          widget.onApply(
                            selectedField,
                            selectedSort,
                            ascending,
                          );
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
      ),
    );
  }
}
