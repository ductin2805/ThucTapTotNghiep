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
      version: 5, // ⚡ nâng version lên
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    await _db!.execute('PRAGMA foreign_keys = ON');
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

    // bảng thanh toán
    await db.execute('''
      CREATE TABLE payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        paid REAL NOT NULL,
        change REAL NOT NULL,
        method TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // bảng hóa đơn (header)
    await db.execute('''
  CREATE TABLE invoices(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    customer TEXT NOT NULL,
    total REAL NOT NULL,
    paid REAL NOT NULL,
    debt REAL NOT NULL,
    method TEXT NOT NULL
  )
''');

    // bảng chi tiết hóa đơn (detail lines)
    await db.execute('''
  CREATE TABLE invoice_items(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_id INTEGER NOT NULL,
    product_id INTEGER,
    name TEXT NOT NULL,
    price REAL NOT NULL,
    quantity INTEGER NOT NULL,
    FOREIGN KEY(invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
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

    if (oldVersion < 4) {
      // v4: tạo bảng payments
      await db.execute('''
        CREATE TABLE payments(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          total REAL NOT NULL,
          paid REAL NOT NULL,
          change REAL NOT NULL,
          method TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('''
    CREATE TABLE invoices(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      customer TEXT NOT NULL,
      total REAL NOT NULL,
      paid REAL NOT NULL,
      debt REAL NOT NULL,
      method TEXT NOT NULL
    )
  ''');

      await db.execute('''
    CREATE TABLE invoice_items(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER NOT NULL,
      product_id INTEGER,
      name TEXT NOT NULL,
      price REAL NOT NULL,
      quantity INTEGER NOT NULL,
      FOREIGN KEY(invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
    )
  ''');
    }
  }
}
