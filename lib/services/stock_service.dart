import '../models/stock_transaction.dart';

/// Business logic untuk perhitungan dan validasi stok.
class StockService {
  StockService._();

  static const String available = 'Available';
  static const String lowStock = 'Low Stock';
  static const String outOfStock = 'Out of Stock';

  /// Smart Low Stock Detection (Core Feature 01).
  static String getStockStatus(double quantity, double minimumStock) {
    if (quantity <= 0) return outOfStock;
    if (quantity <= minimumStock) return lowStock;
    return available;
  }

  /// Menghitung stok baru setelah Stock In / Stock Out.
  /// Hasil dibulatkan 3 desimal untuk menghindari galat floating point.
  static double calculateStockAfterAdjustment(
    double current,
    double change,
    String type,
  ) {
    final result =
        type == StockTransaction.typeIn ? current + change : current - change;
    return double.parse(result.toStringAsFixed(3));
  }

  /// Mengembalikan pesan error, atau null jika input valid.
  static String? validateStockAdjustment({
    required double current,
    required double? change,
    required String type,
  }) {
    if (change == null) return 'Enter a valid number';
    if (change <= 0) return 'Quantity must be greater than zero';
    if (type == StockTransaction.typeOut && change > current) {
      return 'Stock Out cannot exceed available stock';
    }
    return null;
  }

  /// Parse input desimal (mendukung koma maupun titik).
  static double? parseQuantity(String input) =>
      double.tryParse(input.trim().replaceAll(',', '.'));

  /// 5.0 -> "5", 0.5 -> "0.5", 1.250 -> "1.25"
  static String formatQuantity(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    var s = value.toStringAsFixed(3);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    return s;
  }
}
