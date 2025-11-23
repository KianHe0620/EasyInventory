// lib/models/item.model.dart
class Item {
  final String id;
  final String name;
  final int quantity;
  final int minQuantity;
  final double purchasePrice;
  final double sellingPrice;
  final String barcode;
  final String supplier;
  final String field;
  final String imagePath;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    required this.minQuantity,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.barcode,
    required this.supplier,
    required this.field,
    this.imagePath = '',
  });

  Item copyWith({
    String? id,
    String? name,
    int? quantity,
    int? minQuantity,
    double? purchasePrice,
    double? sellingPrice,
    String? barcode,
    String? supplier,
    String? field,
    String? imagePath,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      barcode: barcode ?? this.barcode,
      supplier: supplier ?? this.supplier,
      field: field ?? this.field,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'minQuantity': minQuantity,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'barcode': barcode,
      'supplier': supplier,
      'field': field,
      'imagePath': imagePath,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      quantity: (map['quantity'] is int) ? map['quantity'] : int.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
      minQuantity: (map['minQuantity'] is int) ? map['minQuantity'] : int.tryParse(map['minQuantity']?.toString() ?? '0') ?? 0,
      purchasePrice: (map['purchasePrice'] is num) ? (map['purchasePrice'] as num).toDouble() : double.tryParse(map['purchasePrice']?.toString() ?? '0') ?? 0.0,
      sellingPrice: (map['sellingPrice'] is num) ? (map['sellingPrice'] as num).toDouble() : double.tryParse(map['sellingPrice']?.toString() ?? '0') ?? 0.0,
      barcode: map['barcode']?.toString() ?? '',
      supplier: map['supplier']?.toString() ?? '',
      field: map['field']?.toString() ?? '',
      imagePath: map['imagePath']?.toString() ?? '',
    );
  }
}
