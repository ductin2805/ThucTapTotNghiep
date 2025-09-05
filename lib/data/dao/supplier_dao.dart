import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/supplier.dart';

class SupplierDao {
  static final SupplierDao instance = SupplierDao._init();
  static Database? _database;

  SupplierDao._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('supplier.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        note TEXT,
        logoPath TEXT
      )
    ''');
  }

  Future<int> insert(Supplier supplier) async {
    final db = await instance.database;
    return await db.insert('suppliers', supplier.toMap());
  }

  Future<int> update(Supplier supplier) async {
    final db = await instance.database;
    return await db.update(
      'suppliers',
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'suppliers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Supplier?> getById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'suppliers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Supplier.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Supplier>> getAll() async {
    final db = await instance.database;
    final result = await db.query('suppliers');
    return result.map((map) => Supplier.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
