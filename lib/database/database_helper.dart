import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/item.dart';
import '../models/shopping_item.dart';
import '../models/stock_transaction.dart';

/// Seluruh operasi SQLite OmahSaya.
///
/// Catatan desain:
/// - Barang tidak dihapus permanen, melainkan diarsipkan (`is_archived = 1`)
///   agar riwayat transaksi tetap utuh.
/// - Perubahan stok + pencatatan transaksi selalu dalam satu transaksi database.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  static const List<String> defaultCategories = [
    'Kitchen',
    'Cleaning',
    'Bathroom',
    'Essentials',
    'Food & Beverages',
  ];

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'omahsaya.db'),
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        name TEXT NOT NULL,
        quantity REAL NOT NULL DEFAULT 0,
        unit TEXT NOT NULL,
        minimum_stock REAL NOT NULL DEFAULT 0,
        is_archived INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        quantity REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE shopping_list (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        is_purchased INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE SET NULL
      )
    ''');

    for (final name in defaultCategories) {
      await db.insert('categories', {'name': name});
    }
  }

  // ---------------------------------------------------------------- Categories

  Future<List<ItemCategory>> getCategories() async {
    final db = await database;
    final rows = await db.query('categories', orderBy: 'id ASC');
    return rows.map(ItemCategory.fromMap).toList();
  }

  // --------------------------------------------------------------------- Items

  Future<List<Item>> getItems() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT i.*, c.name AS category_name
      FROM items i
      LEFT JOIN categories c ON c.id = i.category_id
      WHERE i.is_archived = 0
      ORDER BY i.name COLLATE NOCASE ASC
    ''');
    return rows.map(Item.fromMap).toList();
  }

  /// Menambah barang. Jika stok awal > 0, otomatis dicatat sebagai Stock In.
  Future<int> insertItem(Item item) async {
    final db = await database;
    return db.transaction((txn) async {
      final id = await txn.insert('items', item.toMap());
      if (item.quantity > 0) {
        await txn.insert(
          'transactions',
          StockTransaction(
            itemId: id,
            type: StockTransaction.typeIn,
            quantity: item.quantity,
            date: DateTime.now(),
          ).toMap(),
        );
      }
      return id;
    });
  }

  /// Mengubah info barang (nama, kategori, satuan, minimum stok).
  /// Jumlah stok diubah hanya lewat Stock Adjustment.
  Future<void> updateItem(Item item) async {
    final db = await database;
    await db.update(
      'items',
      {
        'category_id': item.categoryId,
        'name': item.name,
        'unit': item.unit,
        'minimum_stock': item.minimumStock,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// "Hapus" barang = arsipkan, riwayat transaksi tetap terjaga.
  Future<void> archiveItem(int id) async {
    final db = await database;
    await db.update(
      'items',
      {'is_archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    // Daftar belanja yang belum dibeli untuk barang ini ikut dibersihkan.
    await db.delete(
      'shopping_list',
      where: 'item_id = ? AND is_purchased = 0',
      whereArgs: [id],
    );
  }

  // -------------------------------------------------------------- Transactions

  /// Update stok + simpan transaksi secara atomik.
  Future<void> adjustStock({
    required int itemId,
    required String type,
    required double change,
    required double newQuantity,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'items',
        {'quantity': newQuantity},
        where: 'id = ?',
        whereArgs: [itemId],
      );
      await txn.insert(
        'transactions',
        StockTransaction(
          itemId: itemId,
          type: type,
          quantity: change,
          date: DateTime.now(),
        ).toMap(),
      );
    });
  }

  Future<List<StockTransaction>> getTransactions({int? limit}) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT t.*, i.name AS item_name, i.unit AS item_unit
      FROM transactions t
      JOIN items i ON i.id = t.item_id
      ORDER BY t.date DESC, t.id DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''');
    return rows.map(StockTransaction.fromMap).toList();
  }

  // ------------------------------------------------------------- Shopping list

  Future<List<ShoppingItem>> getShoppingItems() async {
    final db = await database;
    final rows = await db.query(
      'shopping_list',
      orderBy: 'is_purchased ASC, id DESC',
    );
    return rows.map(ShoppingItem.fromMap).toList();
  }

  Future<int> insertShoppingItem(ShoppingItem item) async {
    final db = await database;
    return db.insert('shopping_list', item.toMap());
  }

  Future<void> updateShoppingQuantity(int id, double quantity) async {
    final db = await database;
    await db.update(
      'shopping_list',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteShoppingItem(int id) async {
    final db = await database;
    await db.delete('shopping_list', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearPurchasedShoppingItems() async {
    final db = await database;
    await db.delete('shopping_list', where: 'is_purchased = 1');
  }

  /// Menandai barang sebagai dibeli. Jika terhubung ke Inventory, stok
  /// bertambah, transaksi Stock In dibuat, dan status pembelian diperbarui
  /// dalam SATU transaksi database (lihat bagian 7.4 dokumen).
  Future<void> purchaseShoppingItem(
    ShoppingItem shoppingItem,
    double purchasedQuantity,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      final itemId = shoppingItem.itemId;
      if (itemId != null) {
        final rows = await txn.query(
          'items',
          columns: ['quantity'],
          where: 'id = ?',
          whereArgs: [itemId],
        );
        if (rows.isNotEmpty) {
          final current = (rows.first['quantity'] as num).toDouble();
          final updated =
              double.parse((current + purchasedQuantity).toStringAsFixed(3));
          await txn.update(
            'items',
            {'quantity': updated},
            where: 'id = ?',
            whereArgs: [itemId],
          );
          await txn.insert(
            'transactions',
            StockTransaction(
              itemId: itemId,
              type: StockTransaction.typeIn,
              quantity: purchasedQuantity,
              date: DateTime.now(),
            ).toMap(),
          );
        }
      }
      await txn.update(
        'shopping_list',
        {'is_purchased': 1, 'quantity': purchasedQuantity},
        where: 'id = ?',
        whereArgs: [shoppingItem.id],
      );
    });
  }
}
