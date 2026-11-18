/// Item pada daftar belanja (tabel `shopping_list`).
class ShoppingItem {
  final int? id;

  /// Boleh null agar barang yang belum terdaftar di Inventory tetap bisa dicatat.
  final int? itemId;
  final String name;
  final double quantity;
  final String unit;
  final bool isPurchased;

  ShoppingItem({
    this.id,
    this.itemId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.isPurchased = false,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'item_id': itemId,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'is_purchased': isPurchased ? 1 : 0,
      };

  factory ShoppingItem.fromMap(Map<String, dynamic> map) => ShoppingItem(
        id: map['id'] as int?,
        itemId: map['item_id'] as int?,
        name: map['name'] as String,
        quantity: (map['quantity'] as num).toDouble(),
        unit: map['unit'] as String,
        isPurchased: (map['is_purchased'] as int) == 1,
      );
}
