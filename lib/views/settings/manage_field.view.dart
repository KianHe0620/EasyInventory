// lib/views/settings/manage_fields.page.dart
import 'package:flutter/material.dart';
import '../../controllers/item.controller.dart';

class ManageFieldsPage extends StatefulWidget {
  final ItemController itemController;
  const ManageFieldsPage({super.key, required this.itemController});

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
    final all = widget.itemController.getFields();
    if (all.contains(txt) || txt == widget.itemController.fallbackField) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Field already exists")));
      return;
    }
    widget.itemController.addField(txt); // persists to firestore
    _newFieldCtrl.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Field added")));
  }

  Future<void> _deleteField(String name) async {
    if (name == widget.itemController.fallbackField) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot delete fallback field")));
      return;
    }

    // count affected items
    final affected = widget.itemController.items.where((it) => it.field == name).length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete field"),
        content: Text(affected == 0
            ? 'Delete field "$name"?'
            : 'Delete field "$name"? This will reassign $affected item(s) to "${widget.itemController.fallbackField}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
        ],
      ),
    );
    if (confirm != true) return;

    // reassign affected items to fallbackField
    final ic = widget.itemController;
    for (var i = 0; i < ic.items.length; i++) {
      final it = ic.items[i];
      if (it.field == name) {
        ic.updateItem(i, it.copyWith(field: ic.fallbackField));
      }
    }

    // remove from customFields (persist)
    widget.itemController.removeField(name);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Field deleted")));
  }

  @override
  Widget build(BuildContext context) {
    // merged fields (fallback + custom + derived)
    final fields = widget.itemController.getFields().toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final custom = widget.itemController.customFields;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Manage Fields")),
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
                      decoration: const InputDecoration(hintText: "Add new field (e.g. Pet, Food)", border: OutlineInputBorder()),
                      onSubmitted: (_) => _addField(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addField, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A84D0),
                      ),
                    child: const Text(
                      "Add",
                      style: TextStyle(color: Colors.white),)
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: fields.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, idx) {
                    final f = fields[idx];
                    final isFallback = f == widget.itemController.fallbackField;
                    final isCustom = custom.contains(f);
                    final derivedCount = widget.itemController.items.where((it) => it.field == f).length;

                    return ListTile(
                      title: Text(f),
                      subtitle: Text(isFallback
                          ? 'Fallback field'
                          : (isCustom ? 'Custom field · $derivedCount item(s)' : 'Derived from items · $derivedCount item(s)')),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isFallback && isCustom)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteField(f),
                              tooltip: "Delete custom field",
                            ),
                        ],
                      ),
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
