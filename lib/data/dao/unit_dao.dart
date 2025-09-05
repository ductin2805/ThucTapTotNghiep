import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/unit.dart';

class UnitDao {
  Future<Database> get _db async => await AppDatabase.instance.db;

  Future<int> insert(Unit unit) async {
    final db = await _db;
    return db.insert("units", unit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Unit unit) async {
    final db = await _db;
    return db.update("units", unit.toMap(),
        where: "id = ?", whereArgs: [unit.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete("units", where: "id = ?", whereArgs: [id]);
  }

  Future<List<Unit>> getAll() async {
    final db = await _db;
    final maps = await db.query("units", orderBy: "id DESC"); // bỏ createdAt
    return maps.map((e) => Unit.fromMap(e)).toList();
  }
}

