import '../models/item.model.dart';

class ItemController {
  final List<Item> items = [];
  String sortBy = "Name";
  bool isAscending = true; // ✅ Track sorting order

    ItemController() {
    // Mock data (demo purposes only)
    items.addAll([
      Item(
        id: "1",
        name: "Cat Food",
        quantity: 10,
        minQuantity: 3,
        purchasePrice: 5.0,
        sellingPrice: 8.0,
        barcode: "111111",
        supplier: "Cat Food Supplier",
        field: "Pet",
        imagePath: "", // leave empty → fallback to icon
      ),
      Item(
        id: "2",
        name: "Dog Toy",
        quantity: 5,
        minQuantity: 2,
        purchasePrice: 2.0,
        sellingPrice: 5.0,
        barcode: "222222",
        supplier: "Dog Toy Supplier",
        field: "Pet",
        imagePath: "", 
      ),
      Item(
        id: "3",
        name: "Orange",
        quantity: 1,
        minQuantity: 1,
        purchasePrice: 15.0,
        sellingPrice: 25.0,
        barcode: "333333",
        supplier: "Orange Supplier",
        field: "Food",
        imagePath: "", 
      ),
    ]);

    sortItems(sortBy); // ✅ ensure initial sorting
  }

  void addItem(Item item) {
    items.add(item);
    sortItems(sortBy); // keep sorted after add
  }

  void updateItem(int index, Item updated) {
    items[index] = updated;
    sortItems(sortBy); // keep sorted after update
  }

  void deleteItem(Item item) {
    items.remove(item);
  }

  void toggleSortOrder() {
    isAscending = !isAscending;
    sortItems(sortBy);
  }

  void sortItems(String criteria) {
    sortBy = criteria;

    int order(int compare) => isAscending ? compare : -compare;

    switch (criteria) {
      case "Quantity":
        items.sort((a, b) => order(a.quantity.compareTo(b.quantity)));
        break;
      case "Price":
        items.sort((a, b) => order(a.sellingPrice.compareTo(b.sellingPrice)));
        break;
      case "Name":
      default:
        items.sort((a, b) => order(a.name.compareTo(b.name)));
        break;
    }
  }
}
