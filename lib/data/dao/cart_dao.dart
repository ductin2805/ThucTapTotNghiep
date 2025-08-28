import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/cart_item.dart';

class CartDao {
  final Database _db = AppDatabase.instance.db;

  Future<int> insert(CartItem item) async {
    return await _db.insert('cart_items', item.toMap());
  }

  Future<List<CartItem>> getAll() async {
    final rows = await _db.query('cart_items', orderBy: 'id DESC');
    return rows.map((r) => CartItem.fromMap(r)).toList();
  }

  Future<int> updateQuantity(int id, int newQuantity) async {
    return await _db.update(
      'cart_items',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    return await _db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    await _db.delete('cart_items');
  }
}
