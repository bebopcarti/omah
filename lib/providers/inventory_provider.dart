import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/item.dart';
import '../models/shopping_item.dart';
import '../models/stock_transaction.dart';
import '../services/stock_service.dart';

/// Penghubung antara UI dan database.
class InventoryProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Item> _items = [];
  List<ItemCategory> _categories = [];
  List<StockTransaction> _transactions = [];
  List<ShoppingItem> _shoppingItems = [];

  String _searchQuery = '';
  int? _selectedCategoryId; // null = All
  bool _isLoading = true;

  // ------------------------------------------------------------------ Getters

  bool get isLoading => _isLoading;
  List<Item> get items => List.unmodifiable(_items);
  List<ItemCategory> get categories => List.unmodifiable(_categories);
  List<StockTransaction> get transactions => List.unmodifiable(_transactions);
  List<ShoppingItem> get shoppingItems => List.unmodifiable(_shoppingItems);
  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;

  /// Search dan Category Filter bekerja bersamaan.
  List<Item> get filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    return _items.where((item) {
      final matchCategory =
          _selectedCategoryId == null || item.categoryId == _selectedCategoryId;
      final matchSearch = query.isEmpty || item.name.toLowerCase().contains(query);
      return matchCategory && matchSearch;
    }).toList();
  }

  // Dashboard: total = jumlah JENIS barang, bukan penjumlahan kuantitas.
  int get totalItems => _items.length;
  int get availableCount =>
      _items.where((i) => i.status == StockService.available).length;
  int get lowStockCount =>
      _items.where((i) => i.status == StockService.lowStock).length;
  int get outOfStockCount =>
      _items.where((i) => i.status == StockService.outOfStock).length;

  /// Barang yang membutuhkan perhatian (Out of Stock tampil lebih dulu).
  List<Item> get needsAttention {
    final list =
        _items.where((i) => i.status != StockService.available).toList();
    list.sort((a, b) {
      final aOut = a.status == StockService.outOfStock ? 0 : 1;
      final bOut = b.status == StockService.outOfStock ? 0 : 1;
      if (aOut != bOut) return aOut.compareTo(bOut);
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  List<StockTransaction> recentActivity([int limit = 5]) =>
      _transactions.take(limit).toList();

  List<ShoppingItem> get pendingShopping =>
      _shoppingItems.where((s) => !s.isPurchased).toList();
  List<ShoppingItem> get purchasedShopping =>
      _shoppingItems.where((s) => s.isPurchased).toList();

  bool isInShoppingList(int? itemId) =>
      itemId != null &&
      _shoppingItems.any((s) => s.itemId == itemId && !s.isPurchased);

  // ------------------------------------------------------------------ Loading

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _categories = await _db.getCategories();
    await _reload();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _reload() async {
    _items = await _db.getItems();
    _transactions = await _db.getTransactions();
    _shoppingItems = await _db.getShoppingItems();
    notifyListeners();
  }

  // ------------------------------------------------------------ Search/Filter

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  // -------------------------------------------------------------------- Items

  Future<void> addItem({
    required String name,
    required int categoryId,
    required double quantity,
    required String unit,
    required double minimumStock,
  }) async {
    final category = _categories.firstWhere((c) => c.id == categoryId);
    await _db.insertItem(Item(
      name: name.trim(),
      categoryId: categoryId,
      category: category.name,
      quantity: quantity,
      unit: unit.trim(),
      minimumStock: minimumStock,
    ));
    await _reload();
  }

  Future<void> updateItem(Item item) async {
    await _db.updateItem(item);
    await _reload();
  }

  Future<void> deleteItem(Item item) async {
    if (item.id == null) return;
    await _db.archiveItem(item.id!);
    await _reload();
  }

  /// Quick Stock Adjustment. Mengembalikan pesan error atau null jika sukses.
  Future<String?> adjustStock({
    required Item item,
    required String type,
    required double? change,
  }) async {
    final error = StockService.validateStockAdjustment(
      current: item.quantity,
      change: change,
      type: type,
    );
    if (error != null) return error;

    final newQuantity = StockService.calculateStockAfterAdjustment(
      item.quantity,
      change!,
      type,
    );
    await _db.adjustStock(
      itemId: item.id!,
      type: type,
      change: change,
      newQuantity: newQuantity,
    );
    await _reload();
    return null;
  }

  // ----------------------------------------------------------------- Shopping

  /// Menambahkan barang Inventory ke Shopping List.
  /// Return false jika sudah ada di daftar (belum dibeli).
  Future<bool> addToShoppingList(Item item) async {
    if (isInShoppingList(item.id)) return false;
    final suggested = item.minimumStock - item.quantity;
    final quantity = suggested > 0 ? suggested : 1.0;
    await _db.insertShoppingItem(ShoppingItem(
      itemId: item.id,
      name: item.name,
      quantity: double.parse(quantity.toStringAsFixed(3)),
      unit: item.unit,
    ));
    await _reload();
    return true;
  }

  Future<void> addCustomShoppingItem({
    required String name,
    required double quantity,
    required String unit,
  }) async {
    await _db.insertShoppingItem(ShoppingItem(
      name: name.trim(),
      quantity: quantity,
      unit: unit.trim(),
    ));
    await _reload();
  }

  Future<void> updateShoppingQuantity(ShoppingItem item, double quantity) async {
    await _db.updateShoppingQuantity(item.id!, quantity);
    await _reload();
  }

  Future<void> removeShoppingItem(ShoppingItem item) async {
    await _db.deleteShoppingItem(item.id!);
    await _reload();
  }

  Future<void> clearPurchased() async {
    await _db.clearPurchasedShoppingItems();
    await _reload();
  }

  Future<void> purchaseShoppingItem(ShoppingItem item, double quantity) async {
    await _db.purchaseShoppingItem(item, quantity);
    await _reload();
  }
}
