// lib/models/sell.model.dart
class Sale {
  final String id;
  final DateTime date;
  final Map<String, int> itemQuantities; // itemId -> qty (new correct format)
  final Map<String, dynamic>? legacyItemQuantities; // optional: old entries keyed by timestamp
  final double totalAmount;

  Sale({
    required this.id,
    required this.date,
    required this.itemQuantities,
    this.legacyItemQuantities,
    required this.totalAmount,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'itemQuantities': itemQuantities,
        'legacyItemQuantities': legacyItemQuantities,
        'totalAmount': totalAmount,
      };

  factory Sale.fromMap(Map<String, dynamic> m) {
    final itemMap = (m['itemQuantities'] as Map<dynamic, dynamic>?) ?? {};
    final legacy = (m['legacyItemQuantities'] as Map<dynamic, dynamic>?)?.map((k, v) => MapEntry(k.toString(), v));
    return Sale(
      id: (m['id'] as String?) ?? '',
      date: DateTime.tryParse((m['date'] as String?) ?? '') ?? DateTime.now(),
      itemQuantities: itemMap.map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
      legacyItemQuantities: legacy == null ? null : Map<String, dynamic>.from(legacy),
      totalAmount: (m['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  String get createdAt {
    final d = date;
    return "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} "
        "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }
}
