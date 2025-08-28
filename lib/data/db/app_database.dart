import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._privateConstructor();
  static final AppDatabase instance = AppDatabase._privateConstructor();

  static Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'pos_local.db');
    // ⚡ reset DB cũ trong giai đoạn dev
    await deleteDatabase(path);

    _db = await openDatabase(
      path,
      version: 3, // ⚡ tăng version mỗi khi thay đổi schema
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Database get db {
    if (_db == null) throw Exception('Database not initialized.');
    return _db!;
  }

  /// Khởi tạo DB mới
  Future _onCreate(Database db, int version) async {
    // bảng sản phẩm
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        img TEXT
      )
    ''');

    // bảng giỏ hàng
    await db.execute('''
      CREATE TABLE cart_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY(product_id) REFERENCES products(id)
      )
    ''');
  }

  /// Migration khi nâng cấp DB
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // v2: thêm cột img cho products
      await db.execute('ALTER TABLE products ADD COLUMN img TEXT');
    }

    if (oldVersion < 3) {
      // v3: tạo bảng cart_items
      await db.execute('''
        CREATE TABLE cart_items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER NOT NULL,
          quantity INTEGER NOT NULL,
          FOREIGN KEY(product_id) REFERENCES products(id)
        )
      ''');
    }

    // ví dụ sau này nếu bạn nâng lên v4, v5...
    // if (oldVersion < 4) { ... }
    // if (oldVersion < 5) { ... }
  }
}
