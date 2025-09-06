import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/category.dart';
import '../../providers/category_provider.dart'; // nơi khai báo categoryListProvider

class CategoryDao {
  Future<Database> get _db async => AppDatabase.instance.db;

  /// ➕ Thêm danh mục
  Future<int> insert(Category category) async {
    final db = await _db;
    return db.insert(
      "categories",
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 📋 Lấy tất cả danh mục
  Future<List<Category>> getAll() async {
    final db = await _db;
    final maps = await db.query("categories", orderBy: "id DESC");
    return maps.map((e) => Category.fromMap(e)).toList();
  }

  /// 🔍 Lấy danh mục theo id
  Future<Category?> getById(int id) async {
    final db = await _db;
    final maps = await db.query(
      "categories",
      where: "id = ?",
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  /// ✏️ Cập nhật danh mục
  Future<int> update(Category category) async {
    final db = await _db;
    return db.update(
      "categories",
      category.toMap(),
      where: "id = ?",
      whereArgs: [category.id],
    );
  }

  /// 🗑️ Xoá danh mục
  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete(
      "categories",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // ✅ Hàm tiện ích: thêm + reload provider
  Future<void> insertAndReload(WidgetRef ref, Category category) async {
    await insert(category);
    ref.invalidate(categoryListProvider);
  }

  // ✅ Hàm tiện ích: update + reload provider
  Future<void> updateAndReload(WidgetRef ref, Category category) async {
    await update(category);
    ref.invalidate(categoryListProvider);
  }

  // ✅ Hàm tiện ích: delete + reload provider
  Future<void> deleteAndReload(WidgetRef ref, int id) async {
    await delete(id);
    ref.invalidate(categoryListProvider);
  }
}
