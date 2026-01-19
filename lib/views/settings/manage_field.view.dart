import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/item.controller.dart';

class ManageFieldsPage extends StatefulWidget {
  final ItemController itemController = Get.find<ItemController>();
  ManageFieldsPage({super.key});

  @override
  State<ManageFieldsPage> createState() => _ManageFieldsPageState();
}

class _ManageFieldsPageState extends State<ManageFieldsPage> {
  final TextEditingController _newFieldCtrl = TextEditingController();

  @override
  void dispose() {
    _newFieldCtrl.dispose();
    super.dispose();
  }

  void _addField() {
    final txt = _newFieldCtrl.text.trim();
    if (txt.isEmpty) return;

    final ic = widget.itemController;
    final all = ic.getFields();

    if (all.contains(txt) || txt == ic.fallbackField) {
      Get.snackbar('Existed', 'Field already exists');
      return;
    }

    ic.addField(txt);
    _newFieldCtrl.clear();
    setState(() {});
    Get.snackbar('Added', 'Field added');
  }

  Future<void> _deleteField(String name) async {
    final ic = widget.itemController;

    if (name == ic.fallbackField) {
      Get.snackbar('Warning', 'Cannot delete fallback field');
      return;
    }

    final affected = ic.items.where((it) => it.field == name).length;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Delete field"),
        content: Text(
          affected == 0
              ? 'Delete field "$name"?'
              : 'Delete field "$name"? $affected item(s) will be moved to "${ic.fallbackField}".',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
              ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white),
              ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    for (var i = 0; i < ic.items.length; i++) {
      final it = ic.items[i];
      if (it.field == name) {
        ic.updateItem(i, it.copyWith(field: ic.fallbackField));
      }
    }

    ic.removeField(name);
    setState(() {});
    Get.snackbar('Deletion', 'Field deleted');
  }

  @override
  Widget build(BuildContext context) {
    final ic = widget.itemController;
    final fallback = ic.fallbackField;

    final allFields = ic.getFields();

    final hasFallbackItems =
        ic.items.any((it) => it.field == fallback);

    final List<String> fields = [];

    if (hasFallbackItems) {
      fields.add(fallback);
    }

    fields.addAll(
      allFields
          .where((f) => f != fallback)
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
    );

    final customFields = ic.customFields;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Fields"),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newFieldCtrl,
                      decoration: const InputDecoration(
                        hintText: "Add new field (e.g. Pet, Food)",
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addField(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addField,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A84D0),
                    ),
                    child: const Text("Add",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: fields.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, idx) {
                    final field = fields[idx];
                    final isFallback = field == fallback;
                    final isCustom = customFields.contains(field);

                    final itemsInField = ic.items
                        .where((it) => it.field == field)
                        .toList();

                    return ListTile(
                      title: Text(
                        field,
                        style: isFallback
                            ? const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              )
                            : null,
                      ),
                      subtitle: isFallback
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Needs attention · ${itemsInField.length} item(s)',
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  itemsInField
                                          .take(3)
                                          .map((e) => e.name)
                                          .join(', ') +
                                      (itemsInField.length > 3 ? ' …' : ''),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              isCustom
                                  ? 'Custom field · ${itemsInField.length} item(s)'
                                  : 'Derived from items · ${itemsInField.length} item(s)',
                            ),
                      trailing: (!isFallback && isCustom)
                          ? IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () => _deleteField(field),
                            )
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
