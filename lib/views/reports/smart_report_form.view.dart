// lib/views/reports/smart_report_form.view.dart
import 'package:easyinventory/views/reports/smart_report.view.dart';
import 'package:flutter/material.dart';
import 'package:easyinventory/controllers/smart_report.controller.dart';
import 'package:easyinventory/models/smart_report.model.dart';

class SmartReportFormPage extends StatefulWidget {
  final SmartReportController controller;

  const SmartReportFormPage({super.key, required this.controller});

  @override
  State<SmartReportFormPage> createState() => _SmartReportFormPageState();
}

class _SmartReportFormPageState extends State<SmartReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  late List<String> fields;

  String? selectedField;
  int eventCount = 0;
  String demandType = "avg30"; // avg7 | avg30 | manual
  String manualDemand = "";
  int targetDays = 30;

  @override
  void initState() {
    super.initState();
    fields = widget.controller.itemController.items
        .map((e) => e.field)
        .toSet()
        .toList()
      ..sort();
    selectedField = fields.isNotEmpty ? fields.first : null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final input = SmartReportInput(
      field: selectedField!,
      upcomingEvents: eventCount,
      demandMode: demandType,
      manualDaily: demandType == "manual" ? double.tryParse(manualDemand) : null,
      targetDays: targetDays,
    );

    final recs = widget.controller.generate(input);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SmartReportResultPage(
          input: input,
          recommendations: recs,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Report")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: selectedField,
                items: fields
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                decoration: const InputDecoration(labelText: "Item Field"),
                onChanged: (v) => setState(() => selectedField = v),
                validator: (v) => v == null || v.isEmpty ? "Please select a field" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(labelText: "Upcoming Events"),
                keyboardType: TextInputType.number,
                initialValue: "0",
                onChanged: (v) => eventCount = int.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: demandType,
                items: const [
                  DropdownMenuItem(value: "avg7", child: Text("Average (7 days)")),
                  DropdownMenuItem(value: "avg30", child: Text("Average (30 days)")),
                  DropdownMenuItem(value: "manual", child: Text("Manual input")),
                ],
                decoration: const InputDecoration(labelText: "Demand Basis"),
                onChanged: (v) => setState(() => demandType = v ?? "avg30"),
              ),
              if (demandType == "manual") ...[
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Manual Daily Demand"),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => manualDemand = v.trim(),
                  validator: (_) {
                    if (demandType != "manual") return null;
                    final d = double.tryParse(manualDemand);
                    if (d == null || d < 0) return "Enter a valid number";
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(labelText: "Target Coverage (days)"),
                keyboardType: TextInputType.number,
                initialValue: "30",
                onChanged: (v) => targetDays = int.tryParse(v) ?? 30,
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Generate"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
