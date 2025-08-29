import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/payment.dart';

class PaymentDao {
  final Database _db = AppDatabase.instance.db;

  Future<int> insert(Payment payment) async {
    return await _db.insert('payments', payment.toMap());
  }

  Future<List<Payment>> getAll() async {
    final rows = await _db.query('payments', orderBy: 'createdAt DESC');
    return rows.map((row) => Payment.fromMap(row)).toList();
  }

  Future<void> clear() async {
    await _db.delete('payments');
  }
}
