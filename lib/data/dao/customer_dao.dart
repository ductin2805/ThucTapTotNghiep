import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/customer.dart';

class CustomerDao {
  final dbProvider = AppDatabase.instance;

  Future<int> insert(Customer customer) async {
    final db = dbProvider.db;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getAll() async {
    final db = dbProvider.db;
    final res = await db.query('customers');
    return res.isNotEmpty
        ? res.map((e) => Customer.fromMap(e)).toList()
        : [];
  }

  Future<int> update(Customer customer) async {
    final db = dbProvider.db;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> delete(int id) async {
    final db = dbProvider.db;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }
}
