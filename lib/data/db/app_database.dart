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
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Database get db {
    if (_db == null) throw Exception('Database not initialized.');
    return _db!;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE products(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      price REAL NOT NULL,
      stock INTEGER NOT NULL,
      img TEXT
    )
  ''');
  }

}