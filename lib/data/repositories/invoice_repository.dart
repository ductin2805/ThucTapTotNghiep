import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class InvoiceRepository {
  final Database db = AppDatabase.instance.db;

  /// Thêm mới hóa đơn và chi tiết
  Future<int> insertInvoice(Invoice invoice, List<InvoiceItem> items) async {
    return await db.transaction((txn) async {
      // 1. Insert hóa đơn
      final invoiceId = await txn.insert('invoices', invoice.toMap());

      // 2. Insert các item
      for (var item in items) {
        final newItem = item.toMap()..['invoice_id'] = invoiceId;
        await txn.insert('invoice_items', newItem);
      }

      return invoiceId;
    });
  }

  /// Lấy danh sách hóa đơn
  Future<List<Invoice>> getAllInvoices() async {
    final rows = await db.query('invoices', orderBy: 'createdAt DESC');
    return rows.map((r) => Invoice.fromMap(r)).toList();
  }

  /// Lấy chi tiết theo invoiceId
  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    final rows = await db.query(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );
    return rows.map((r) => InvoiceItem.fromMap(r)).toList();
  }

  /// Xóa hóa đơn (sẽ xóa cả items nhờ foreign key ON DELETE CASCADE)
  Future<int> deleteInvoice(int id) async {
    return await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }
}
