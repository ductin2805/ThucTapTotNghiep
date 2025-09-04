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
      version: 7, // tăng version để tránh xung đột cũ
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
        tax INTEGER DEFAULT 0,
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
        createdAt TEXT NOT NULL,
        customerId INTEGER,
        FOREIGN KEY(customerId) REFERENCES customers(id)
      )
    ''');

    // bảng hóa đơn
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

    // bảng chi tiết hóa đơn
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

    // bảng thông tin cửa hàng
    await db.execute('''
      CREATE TABLE store_info(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        website TEXT,
        other TEXT,
        logoPath TEXT
      )
    ''');

    // bảng khách hàng
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        address TEXT,
        note TEXT,
        imagePath TEXT
      )
    ''');
  }

  /// Migration khi nâng cấp DB
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE products ADD COLUMN img TEXT');
    }

    if (oldVersion < 3) {
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
      await db.execute('''
        CREATE TABLE payments(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          total REAL NOT NULL,
          paid REAL NOT NULL,
          change REAL NOT NULL,
          method TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          customerId INTEGER,
          FOREIGN KEY(customerId) REFERENCES customers(id)
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
    }

    if (oldVersion < 6) {
      await db.execute("ALTER TABLE products ADD COLUMN code TEXT");
      await db.execute("ALTER TABLE products ADD COLUMN barcode TEXT");
      await db.execute("ALTER TABLE products ADD COLUMN costPrice REAL DEFAULT 0");
      await db.execute("ALTER TABLE products ADD COLUMN unit TEXT DEFAULT 'Cái'");
      await db.execute("ALTER TABLE products ADD COLUMN category TEXT DEFAULT 'Mặc định'");
      await db.execute("ALTER TABLE products ADD COLUMN tax INTEGER DEFAULT 0");
      await db.execute("ALTER TABLE products ADD COLUMN note TEXT");
    }

    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE store_info(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          phone TEXT,
          email TEXT,
          address TEXT,
          website TEXT,
          other TEXT,
          logoPath TEXT
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

extension Reports on AppDatabase {
  /// Báo cáo theo filter (thời gian + loại hóa đơn)
  Future<ReportSummary> getReportByFilter(String time, String invoice) async {
    final db = this.db;

    String whereTime = "";
    List<dynamic> timeArgs = [];
    final now = DateTime.now();

    if (time == "Hôm nay") {
      final todayStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      whereTime = "date(inv.createdAt) = ?";
      timeArgs.add(todayStr);
    } else if (time == "Hôm qua") {
      final yesterday = now.subtract(const Duration(days: 1));
      final yStr =
          "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
      whereTime = "date(inv.createdAt) = ?";
      timeArgs.add(yStr);
    } else if (time == "Tuần này") {
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      whereTime = "date(inv.createdAt) BETWEEN ? AND ?";
      timeArgs.addAll([
        "${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}",
        "${weekEnd.year}-${weekEnd.month.toString().padLeft(2, '0')}-${weekEnd.day.toString().padLeft(2, '0')}",
      ]);
    } else if (time == "Tuần trước") {
      final lastWeekEnd = now.subtract(Duration(days: now.weekday));
      final lastWeekStart = lastWeekEnd.subtract(const Duration(days: 6));
      whereTime = "date(inv.createdAt) BETWEEN ? AND ?";
      timeArgs.addAll([
        "${lastWeekStart.year}-${lastWeekStart.month.toString().padLeft(2, '0')}-${lastWeekStart.day.toString().padLeft(2, '0')}",
        "${lastWeekEnd.year}-${lastWeekEnd.month.toString().padLeft(2, '0')}-${lastWeekEnd.day.toString().padLeft(2, '0')}",
      ]);
    } else if (time == "Tháng này") {
      final monthStr = "${now.year}-${now.month.toString().padLeft(2, '0')}";
      whereTime = "strftime('%Y-%m', inv.createdAt) = ?";
      timeArgs.add(monthStr);
    } else if (time == "Tháng trước") {
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      final lastMonthStr =
          "${lastMonth.year}-${lastMonth.month.toString().padLeft(2, '0')}";
      whereTime = "strftime('%Y-%m', inv.createdAt) = ?";
      timeArgs.add(lastMonthStr);
    } else {
      whereTime = "1=1"; // tất cả
    }

    String whereInvoice = "";
    List<dynamic> invoiceArgs = [];
    if (invoice != "Tất cả") {
      whereInvoice = "AND inv.method = ?";
      invoiceArgs.add(invoice.toLowerCase());
    }

    String where = "$whereTime $whereInvoice";
    List<dynamic> args = [...timeArgs, ...invoiceArgs];

    // Hóa đơn
    final invoiceData = await db.rawQuery('''
      SELECT COUNT(*) as count, 
             COALESCE(SUM(total), 0) as total, 
             COALESCE(SUM(debt), 0) as debt
      FROM invoices inv
      WHERE $where
    ''', args);

    final invoiceCount = (invoiceData.first['count'] as int?) ?? 0;
    final invoiceValue = (invoiceData.first['total'] as num?)?.toDouble() ?? 0;
    final debt = (invoiceData.first['debt'] as num?)?.toDouble() ?? 0;

    final revenue = invoiceValue;

    // Vốn
    final costData = await db.rawQuery('''
      SELECT COALESCE(SUM(p.costPrice * ii.quantity), 0) as cost
      FROM invoice_items ii
      INNER JOIN products p ON ii.product_id = p.id
      INNER JOIN invoices inv ON ii.invoice_id = inv.id
      WHERE $where
    ''', args);

    final cost = (costData.first['cost'] as num?)?.toDouble() ?? 0;
    final profit = revenue - cost;

    // Thanh toán (cash/bank)
    final payData = await db.rawQuery('''
      SELECT method, SUM(paid) as sumPaid
      FROM invoices inv
      WHERE $where
      GROUP BY method
    ''', args);

    double cash = 0, bank = 0;
    for (final row in payData) {
      final method = (row['method'] as String?) ?? "";
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
