import 'package:flutter_test/flutter_test.dart';
import 'package:omahsaya/models/stock_transaction.dart';
import 'package:omahsaya/services/stock_service.dart';

void main() {
  group('getStockStatus', () {
    test('quantity 0 -> Out of Stock', () {
      expect(StockService.getStockStatus(0, 2), StockService.outOfStock);
    });
    test('quantity <= minimum -> Low Stock', () {
      expect(StockService.getStockStatus(1, 2), StockService.lowStock);
      expect(StockService.getStockStatus(2, 2), StockService.lowStock);
    });
    test('quantity > minimum -> Available', () {
      expect(StockService.getStockStatus(5, 2), StockService.available);
    });
  });

  group('calculateStockAfterAdjustment', () {
    test('Stock In menambah', () {
      expect(
        StockService.calculateStockAfterAdjustment(
            2, 5, StockTransaction.typeIn),
        7,
      );
    });
    test('Stock Out mengurangi (2 L - 0.5 L = 1.5 L)', () {
      expect(
        StockService.calculateStockAfterAdjustment(
            2, 0.5, StockTransaction.typeOut),
        1.5,
      );
    });
  });

  group('validateStockAdjustment', () {
    test('menolak input kosong / bukan angka', () {
      expect(
        StockService.validateStockAdjustment(
            current: 2, change: null, type: StockTransaction.typeIn),
        isNotNull,
      );
    });
    test('menolak jumlah nol atau negatif', () {
      expect(
        StockService.validateStockAdjustment(
            current: 2, change: 0, type: StockTransaction.typeIn),
        isNotNull,
      );
    });
    test('menolak Stock Out melebihi stok', () {
      expect(
        StockService.validateStockAdjustment(
            current: 2, change: 3, type: StockTransaction.typeOut),
        isNotNull,
      );
    });
    test('menerima input valid', () {
      expect(
        StockService.validateStockAdjustment(
            current: 2, change: 0.5, type: StockTransaction.typeOut),
        isNull,
      );
    });
  });

  group('format & parse', () {
    test('parseQuantity mendukung koma', () {
      expect(StockService.parseQuantity('0,5'), 0.5);
    });
    test('formatQuantity merapikan angka', () {
      expect(StockService.formatQuantity(5), '5');
      expect(StockService.formatQuantity(0.5), '0.5');
      expect(StockService.formatQuantity(1.25), '1.25');
    });
  });
}
