class Sell {
  final String id;
  final DateTime date;
  final Map<String, int> itemQuantities; 
  // key: itemId, value: quantity sold
  final double totalAmount;

  Sell({
    required this.id,
    required this.date,
    required this.itemQuantities,
    required this.totalAmount,
  });
}
