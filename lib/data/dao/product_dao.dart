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

  Future<int> updateStock(int id, int newStock) async {
    return await _db.update(
      'products',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    return await _db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
