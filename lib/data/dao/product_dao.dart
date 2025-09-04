import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/product.dart';

class ProductDao {
  final Database _db = AppDatabase.instance.db;

  Future<int> insert(Product product) async {
    return await _db.insert('products', product.toMap());
  }

  Future<List<Product>> getAll() async {
    final rows = await _db.query('products', orderBy: 'id DESC');
    return rows.map((r) => Product.fromMap(r)).toList();
  }

  Future<void> updateStock(int id, int newStock) async {
    final db = AppDatabase.instance.db;
    await db.update(
      'products',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> update(Product product) async {
    return await _db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> delete(int id) async {
    return await _db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<Product?> getById(int id) async {
    final res = await _db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (res.isNotEmpty) {
      return Product.fromMap(res.first);
    }
    return null;
  }
}
