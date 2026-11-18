import '../services/stock_service.dart';

/// Kategori barang (tabel `categories`).
class ItemCategory {
  final int id;
  final String name;

  const ItemCategory({required this.id, required this.name});

  factory ItemCategory.fromMap(Map<String, dynamic> map) =>
      ItemCategory(id: map['id'] as int, name: map['name'] as String);
}

/// Barang rumah tangga (tabel `items`).
class Item {
  final int? id;
  final String name;
  final int? categoryId;

  /// Nama kategori (hasil join dengan tabel `categories`).
  final String category;
  final double quantity;
  final String unit;
  final double minimumStock;

  Item({
    this.id,
    required this.name,
    this.categoryId,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minimumStock,
  });

  /// Status stok dihitung otomatis (Smart Low Stock Detection).
  String get status => StockService.getStockStatus(quantity, minimumStock);

  Item copyWith({
    int? id,
    String? name,
    int? categoryId,
    String? category,
    double? quantity,
    String? unit,
    double? minimumStock,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      minimumStock: minimumStock ?? this.minimumStock,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'category_id': categoryId,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'minimum_stock': minimumStock,
      };

  factory Item.fromMap(Map<String, dynamic> map) => Item(
        id: map['id'] as int?,
        name: map['name'] as String,
        categoryId: map['category_id'] as int?,
        category: (map['category_name'] as String?) ?? 'Uncategorized',
        quantity: (map['quantity'] as num).toDouble(),
        unit: map['unit'] as String,
        minimumStock: (map['minimum_stock'] as num).toDouble(),
      );
}
