/// Catatan perubahan stok (tabel `transactions`).
class StockTransaction {
  static const String typeIn = 'IN';
  static const String typeOut = 'OUT';

  final int? id;
  final int itemId;
  final String type;
  final double quantity;
  final DateTime date;

  /// Hasil join dengan tabel `items`, hanya untuk tampilan riwayat.
  final String? itemName;
  final String? unit;

  StockTransaction({
    this.id,
    required this.itemId,
    required this.type,
    required this.quantity,
    required this.date,
    this.itemName,
    this.unit,
  });

  bool get isIn => type == typeIn;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'item_id': itemId,
        'type': type,
        'quantity': quantity,
        'date': date.toIso8601String(),
      };

  factory StockTransaction.fromMap(Map<String, dynamic> map) =>
      StockTransaction(
        id: map['id'] as int?,
        itemId: map['item_id'] as int,
        type: map['type'] as String,
        quantity: (map['quantity'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        itemName: map['item_name'] as String?,
        unit: map['item_unit'] as String?,
      );
}
