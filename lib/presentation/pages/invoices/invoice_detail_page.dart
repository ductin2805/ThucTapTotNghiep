import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/db/app_database.dart';

class InvoiceDetailPage extends StatefulWidget {
  final int invoiceId;

  const InvoiceDetailPage({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  late Future<Map<String, dynamic>> _futureInvoice;

  @override
  void initState() {
    super.initState();
    _futureInvoice = _loadInvoiceDetail();
  }

  Future<Map<String, dynamic>> _loadInvoiceDetail() async {
    final db = AppDatabase.instance.db;

    // lấy hóa đơn
    final invoiceRows = await db.query(
      "payments",
      where: "id = ?",
      whereArgs: [widget.invoiceId],
      limit: 1,
    );

    if (invoiceRows.isEmpty) throw Exception("Không tìm thấy hóa đơn");

    final invoice = invoiceRows.first;

    // lấy các item thuộc hóa đơn này
    final items = await db.query(
      "invoice_items",
      where: "invoice_id = ?",
      whereArgs: [widget.invoiceId],
    );

    return {
      "invoice": invoice,
      "items": items,
    };
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết hóa đơn")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureInvoice,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          final data = snapshot.data!;
          final invoice = data["invoice"] as Map<String, dynamic>;
          final items = data["items"] as List<Map<String, dynamic>>;

          final createdAt = DateTime.tryParse(invoice["createdAt"]) ?? DateTime.now();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin hóa đơn
                Text(
                  "Hóa đơn #${invoice["id"]}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text("Ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(createdAt)}"),
                Text("Khách hàng: Khách lẻ"),
                const Divider(height: 32),

                // Danh sách sản phẩm
                const Text("Sản phẩm:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...items.map((item) => ListTile(
                  title: Text(item["name"] ?? ""),
                  subtitle: Text("SL: ${item["quantity"]} x ${currency.format(item["price"])}"),
                  trailing: Text(
                    currency.format(item["quantity"] * item["price"]),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )),

                const Divider(height: 32),

                // Tổng cộng
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Tổng tiền: ${currency.format(invoice["total"])}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("Khách trả: ${currency.format(invoice["paid"])}"),
                      Text("Còn nợ: ${currency.format(invoice["debt"] ?? 0)}"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
