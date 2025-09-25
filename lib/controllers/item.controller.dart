import 'package:flutter/foundation.dart';
import '../models/item.model.dart';

class ItemController extends ChangeNotifier {
  final List<Item> items = [];

  // Search, filter & sort state
  String searchQuery = "";
  Set<String> activeFields = {}; // empty = all
  String sortBy = "Name";
  bool ascending = true;

  // Selection mode state
  bool selectionMode = false;
  final Set<String> selectedIds = {};

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
        imagePath: "",
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

    sortItems(sortBy);
  }

  // --- CRUD ---
  void addItem(Item item) {
    items.add(item);
    sortItems(sortBy);
    notifyListeners();
  }

  void updateItem(int index, Item updated) {
    items[index] = updated;
    sortItems(sortBy);
    notifyListeners();
  }

  void deleteItem(Item item) {
    items.remove(item);
    notifyListeners();
  }

  void deleteSelected() {
    items.removeWhere((it) => selectedIds.contains(it.id));
    selectedIds.clear();
    selectionMode = false;
    notifyListeners();
  }

  // --- Filtering, Searching, Sorting ---
  void setSearchQuery(String query) {
    searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void applyFilter(Set<String> fields, String sort, bool asc) {
    activeFields = fields;
    sortBy = sort;
    ascending = asc;
    sortItems(sortBy);
    notifyListeners();
  }

  void resetFilters() {
    activeFields.clear();
    sortBy = "Name";
    ascending = true;
    notifyListeners();
  }

  void toggleSortOrder() {
    ascending = !ascending;
    sortItems(sortBy);
    notifyListeners();
  }

  void sortItems(String criteria) {
    sortBy = criteria;

    int order(int cmp) => ascending ? cmp : -cmp;

    switch (criteria) {
      case "Quantity":
        items.sort((a, b) => order(a.quantity.compareTo(b.quantity)));
        break;
      case "Price":
        items.sort((a, b) => order(a.sellingPrice.compareTo(b.sellingPrice)));
        break;
      case "Field":
        items.sort((a, b) => order(a.field.compareTo(b.field)));
        break;
      case "Name":
      default:
        items.sort((a, b) => order(a.name.compareTo(b.name)));
        break;
    }
  }

  List<Item> getFilteredSortedItems() {
    final filtered = items.where((item) {
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();

        final matchName = item.name.toLowerCase().contains(query);
        final matchBarcode = item.barcode.contains(query); // keep order exact

        if (!matchName && !matchBarcode) {
          return false;
        }
      }

      if (activeFields.isNotEmpty && !activeFields.contains(item.field)) {
        return false;
      }
      return true;
    }).toList();

    return filtered;
  }


  // --- Selection mode ---
  void toggleSelectionMode() {
    selectionMode = !selectionMode;
    if (!selectionMode) selectedIds.clear();
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    notifyListeners();
  }
}
