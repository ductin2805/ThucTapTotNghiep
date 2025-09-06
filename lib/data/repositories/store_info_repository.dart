import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/store_info.dart';

class StoreInfoRepository {
  final Database db = AppDatabase.instance.db;

  Future<StoreInfo?> getStoreInfo() async {
    final maps = await db.query("store_info", limit: 1);
    if (maps.isNotEmpty) {
      return StoreInfo.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertStoreInfo(StoreInfo info) async {
    return await db.insert("store_info", info.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateStoreInfo(StoreInfo info) async {
    return await db.update(
      "store_info",
      info.toMap(),
      where: "id = ?",
      whereArgs: [info.id],
    );
  }
}
