class Item {
  String id;
  String name;
  int quantity;
  int minQuantity;
  double purchasePrice;
  double sellingPrice;
  String barcode;
  String supplier;
  String field;
  String imagePath;

  Item({
    required this.id,
    required this.name,
    this.quantity = 0,
    this.minQuantity = 0,
    this.purchasePrice = 0.0,
    this.sellingPrice = 0.0,
    this.barcode = '',
    required this.supplier,
    required this.field,
    this.imagePath = ''
  });

  double get totalPurchase => purchasePrice * quantity;
  double get totalSelling => sellingPrice * quantity;

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
}
