// lib/views/sell/sale_history.page.dart
import 'package:flutter/material.dart';
import '../../controllers/sell.controller.dart';
import '../../controllers/item.controller.dart';
import '../../models/sell.model.dart';
import '../../models/item.model.dart';

class SaleHistoryPage extends StatefulWidget {
  final SellController sellController;
  final ItemController itemController;

  const SaleHistoryPage({
    super.key,
    required this.sellController,
    required this.itemController,
  });

  @override
  State<SaleHistoryPage> createState() => _SaleHistoryPageState();
}

class _SaleHistoryPageState extends State<SaleHistoryPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  // helper to show date in readable form
  String _prettyDate(DateTime d) {
    return "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickStartDate() async {
    final initial = _startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = DateTime(picked.year, picked.month, picked.day);
        // ensure start <= end
        if (_endDate != null && _endDate!.isBefore(_startDate!)) _endDate = _startDate;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final initial = _endDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        // make end inclusive by setting to end of day when filtering
        _endDate = DateTime(picked.year, picked.month, picked.day);
        if (_startDate != null && _startDate!.isAfter(_endDate!)) _startDate = _endDate;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  bool _inRange(DateTime date) {
    // treat null as unbounded
    final start = _startDate != null ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day, 0, 0, 0) : null;
    final end = _endDate != null ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59) : null;
    if (start != null && date.isBefore(start)) return false;
    if (end != null && date.isAfter(end)) return false;
    return true;
  }

  List<Sale> _applyDateFilter(List<Sale> sales) {
    if (_startDate == null && _endDate == null) return sales;
    return sales.where((s) => _inRange(s.date)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        actions: [
          IconButton(
            tooltip: 'Clear date filter',
            icon: const Icon(Icons.clear),
            onPressed: _clearFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickStartDate,
                    child: Text(_startDate == null ? 'Start date' : 'Start: ${_prettyDate(_startDate!)}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickEndDate,
                    child: Text(_endDate == null ? 'End date' : 'End: ${_prettyDate(_endDate!)}'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // refresh list with the currently selected date range
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),

          // List area
          Expanded(
            child: StreamBuilder<List<Sale>>(
              stream: widget.sellController.salesStream(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Error loading sales: ${snap.error}'));
                }

                // treat missing data as empty list (prevents indefinite spinner)
                final allSales = snap.data ?? [];

                // apply date filter locally
                final filtered = _applyDateFilter(allSales);

                if (filtered.isEmpty) {
                  // provide friendly feedback depending on whether filter was set
                  if (_startDate != null || _endDate != null) {
                    return Center(child: Text('No sales in selected date range.'));
                  } else {
                    return const Center(child: Text('No sale history'));
                  }
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final s = filtered[i];
                    final itemCount = s.itemQuantities.isNotEmpty
                        ? s.itemQuantities.length
                        : (s.legacyItemQuantities?.length ?? 0);

                    return ListTile(
                      title: Text('Sale: RM ${s.totalAmount.toStringAsFixed(2)}'),
                      subtitle: Text('${s.createdAt} • $itemCount items'),
                      onTap: () {
                        String details = '';

                        if (s.itemQuantities.isNotEmpty) {
                          details = s.itemQuantities.entries.map((e) {
                            final itemId = e.key;
                            final qty = e.value;
                            final name = (() {
                              try {
                                final it = widget.itemController.items.firstWhere((it) => it.id == itemId);
                                return it.name;
                              } catch (_) {
                                return 'Unknown item ($itemId)';
                              }
                            })();
                            return '$name: $qty';
                          }).join('\n');
                        } else {
                          final legacy = s.legacyItemQuantities ?? {};
                          if (legacy.isEmpty) {
                            details = '(No item details available)';
                          } else {
                            details = legacy.entries.map((e) => 'Legacy Entry (${e.key}): ${e.value}').join('\n');
                          }
                        }

                        showDialog(
                          context: context,
                          builder: (dctx) => AlertDialog(
                            title: const Text('Sale details'),
                            content: Text('Date: ${s.createdAt}\n\n$details\n\nTotal: RM ${s.totalAmount.toStringAsFixed(2)}'),
                            actions: [TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('OK'))],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
