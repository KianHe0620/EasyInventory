import 'package:easyinventory/views/reports/smart_report_result.page.dart';
import 'package:flutter/material.dart';
import 'package:easyinventory/controllers/smart_report.controller.dart';
import 'package:easyinventory/models/smart_report.model.dart';
import 'package:get/get.dart';

class SmartReportFormPage extends StatefulWidget {
  final SmartReportController smartReportController = Get.find<SmartReportController>();
  SmartReportFormPage({super.key});

  @override
  State<SmartReportFormPage> createState() => _SmartReportFormPageState();
}

class _SmartReportFormPageState extends State<SmartReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  late List<String> fields;

  String? selectedField;
  int upcomingEventDays = 0;
  String demandType = "ema";
  int targetDays = 30;
  int windowDays = 30;
  int minOrder = 1;
  int packSize = 1;
  bool enforceCap = false;

  @override
  void initState() {
    super.initState();
    final setFields = widget.smartReportController.itemController.getFields();
    fields = <String>['All', ...setFields.toList()..sort()];
    selectedField = fields.isNotEmpty ? fields.first : 'All';
  }

  void _openHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Field help (short)'),
        content: SizedBox(
          width: double.maxFinite,
          child: Scrollbar(
            child: ListView(
              shrinkWrap: true,
              children: const [
                _HelpRow(
                  title: 'Item Field',
                  desc: 'Choose which category of items to analyze. Choose "All" to include every item.',
                ),
                _HelpRow(
                  title: 'Upcoming event days (total)',
                  desc: 'Enter how many future days will have higher-than-normal sales (e.g. promotions, events). The system will boost demand for those days.',
                ),
                _HelpRow(
                  title: 'Demand Basis',
                  desc: 'Average computes historical mean demand, while EMA applies smoothing to prioritize recent sales trends.',
                ),
                _HelpRow(
                  title: 'Target Coverage (days)',
                  desc: 'How many days of stock you want to cover (common choices: 7, 14, 30).',
                ),
                _HelpRow(
                  title: 'Analysis Window (days)',
                  desc: 'How many past days to use when evaluating data quality (variance, confidence, non-zero days).',
                ),
                _HelpRow(
                  title: 'Minimum Order Quantity',
                  desc: 'Supplier minimum order size (if any). The suggested quantity will be rounded up to meet this.',
                ),
                _HelpRow(
                  title: 'Pack Size',
                  desc: 'If items are sold in packs (e.g. 6 per pack, 24 per case), enter the pack size so suggestions are aligned to full packs.',
                ),
                _HelpRow(
                  title: 'Enforce Safety Cap',
                  desc: 'If ON, suggestions will be limited by the safety cap. If OFF, the cap is shown as advisory only.',
                ),
                _HelpRow(
                  title: 'Why an item might not appear',
                  desc: 'If current stock already meets the target or the item is not in the selected field, it will not appear in the recommendation list.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final input = SmartReportInput(
      field: selectedField ?? 'All',
      upcomingEventDays: upcomingEventDays,
      demandMode: demandType,
      targetDays: targetDays,
      windowDays: windowDays,
      minOrder: minOrder > 0 ? minOrder : null,
      packSize: packSize > 1 ? packSize : null,
      enforceCap: enforceCap,
    );

    final recs = widget.smartReportController.generate(input);

    Get.to(() => SmartReportResultPage(
          input: input,
          recommendations: recs,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Smart Report"),
        actions: [
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline),
            onPressed: _openHelpDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedField,
                items: fields.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                decoration: const InputDecoration(labelText: "Item Field"),
                onChanged: (v) => setState(() => selectedField = v),
                validator: (v) => v == null ? "Please select a field" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: "Upcoming event days (total)"),
                keyboardType: TextInputType.number,
                initialValue: "0",
                onChanged: (v) => upcomingEventDays = int.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: demandType,
                items: const [
                  DropdownMenuItem(value: "avg", child: Text("Average")),
                  DropdownMenuItem(value: "ema", child: Text("EMA (Smooth)")),
                ],
                decoration: const InputDecoration(labelText: "Demand Basis"),
                onChanged: (v) => setState(() => demandType = v ?? "ema"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: "Target Coverage (days)"),
                keyboardType: TextInputType.number,
                initialValue: "30",
                onChanged: (v) => targetDays = int.tryParse(v) ?? 30,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: windowDays,
                items: const [
                  DropdownMenuItem(value: 7, child: Text("Last 7 days (more responsive)")),
                  DropdownMenuItem(value: 14, child: Text("Last 14 days (balanced)")),
                  DropdownMenuItem(value: 30, child: Text("Last 30 days (most stable)")),
                ],
                decoration: const InputDecoration(labelText: "Analysis Window (days)"),
                onChanged: (v) => setState(() => windowDays = v ?? 30),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: "Minimum Order Quantity (optional)"),
                keyboardType: TextInputType.number,
                initialValue: "1",
                onChanged: (v) => minOrder = int.tryParse(v) ?? 1,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: "Pack Size (optional, e.g. 6)"),
                keyboardType: TextInputType.number,
                initialValue: "1",
                onChanged: (v) => packSize = int.tryParse(v) ?? 1,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: enforceCap,
                onChanged: (v) => setState(() => enforceCap = v),
                title: const Text("Enforce safety cap"),
                subtitle: const Text("When ON, suggestions are limited by the safety cap. Default: OFF (advisory)"),
              ),
              const SizedBox(height: 18),
              ElevatedButton(onPressed: _submit, child: const Text("Generate")),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  final String title;
  final String desc;
  const _HelpRow({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(desc),
      ]),
    );
  }
}
