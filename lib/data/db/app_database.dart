import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/report_summary.dart';

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
      code TEXT,
      barcode TEXT,
      price REAL NOT NULL,
      costPrice REAL DEFAULT 0,
      stock INTEGER NOT NULL,
      unit TEXT DEFAULT 'Cái',
      category TEXT DEFAULT 'Mặc định',
      tax INTEGER DEFAULT 0, -- 0: không, 1: có
      note TEXT,
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

      if (oldVersion < 6) {
        await db.execute("ALTER TABLE products ADD COLUMN code TEXT");
        await db.execute("ALTER TABLE products ADD COLUMN barcode TEXT");
        await db.execute("ALTER TABLE products ADD COLUMN costPrice REAL DEFAULT 0");
        await db.execute("ALTER TABLE products ADD COLUMN unit TEXT DEFAULT 'Cái'");
        await db.execute("ALTER TABLE products ADD COLUMN category TEXT DEFAULT 'Mặc định'");
        await db.execute("ALTER TABLE products ADD COLUMN tax INTEGER DEFAULT 0");
        await db.execute("ALTER TABLE products ADD COLUMN note TEXT");
      }


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
extension Reports on AppDatabase {
  /// Báo cáo theo ngày cụ thể (hôm nay, tuần này, tháng này, tất cả...)
  Future<ReportSummary> getReportByFilter(String time, String invoice) async {
    final db = this.db;

    // Xác định điều kiện thời gian
    String whereTime = "";
    List<dynamic> args = [];

    final now = DateTime.now();
    if (time == "Hôm nay") {
      final todayStr =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      whereTime = "date(inv.createdAt) = ?";
      args.add(todayStr);
    } else if (time == "Tuần này") {
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      whereTime = "date(inv.createdAt) BETWEEN ? AND ?";
      args.addAll([
        "${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}",
        "${weekEnd.year}-${weekEnd.month.toString().padLeft(2, '0')}-${weekEnd.day.toString().padLeft(2, '0')}"
      ]);
    } else if (time == "Tháng này") {
      final monthStr =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}";
      whereTime = "strftime('%Y-%m', inv.createdAt) = ?";
      args.add(monthStr);
    } else {
      whereTime = "1=1"; // tất cả
    }

    // Xác định điều kiện loại hóa đơn (nếu có)
    String whereInvoice = "";
    if (invoice != "Tất cả") {
      whereInvoice = "AND inv.method = ?";
      args.add(invoice.toLowerCase());
    }

    // Lấy dữ liệu hóa đơn
    final invoiceData = await db.rawQuery('''
      SELECT COUNT(*) as count, SUM(total) as total, SUM(debt) as debt
      FROM invoices inv
      WHERE $whereTime $whereInvoice
    ''', args);

    final invoiceCount = invoiceData.first['count'] as int? ?? 0;
    final invoiceValue = (invoiceData.first['total'] as num?)?.toDouble() ?? 0;
    final debt = (invoiceData.first['debt'] as num?)?.toDouble() ?? 0;

    final revenue = invoiceValue;

    // Tính vốn
    final costData = await db.rawQuery('''
      SELECT COALESCE(SUM(p.costPrice * ii.quantity), 0) as cost
      FROM invoice_items ii
      INNER JOIN products p ON ii.product_id = p.id
      INNER JOIN invoices inv ON ii.invoice_id = inv.id
      WHERE $whereTime $whereInvoice
    ''', args);

    final cost = (costData.first['cost'] as num?)?.toDouble() ?? 0;
    final profit = revenue - cost;

    // Tiền mặt / ngân hàng
    final payData = await db.rawQuery('''
      SELECT method, SUM(paid) as sumPaid
      FROM invoices inv
      WHERE $whereTime $whereInvoice
      GROUP BY method
    ''', args);

    double cash = 0, bank = 0;
    for (final row in payData) {
      final method = row['method'] as String;
      final sumPaid = (row['sumPaid'] as num?)?.toDouble() ?? 0;
      if (method == "cash") cash = sumPaid;
      if (method == "bank") bank = sumPaid;
    }

    return ReportSummary(
      profit: profit,
      revenue: revenue,
      invoiceCount: invoiceCount,
      invoiceValue: invoiceValue,
      tax: 0,
      discount: 0,
      cost: cost,
      cash: cash,
      bank: bank,
      debt: debt,
    );
  }
}


