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

    // ⚡ lấy hóa đơn từ bảng invoices
    final invoiceRows = await db.query(
      "invoices",
      where: "id = ?",
      whereArgs: [widget.invoiceId],
      limit: 1,
    );

    if (invoiceRows.isEmpty) throw Exception("Không tìm thấy hóa đơn");

    final invoice = invoiceRows.first;

    // ⚡ lấy danh sách sản phẩm từ bảng invoice_items
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true); // ✅ back trả về true
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Chi tiết hóa đơn"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
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

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ⚡ Thông tin hóa đơn
                        Text("Đơn hàng: DH.${invoice["id"]}",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(createdAt)}"),
                        Text("Khách hàng: ${invoice["customer"]}",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Divider(height: 32),

                        // ⚡ Danh sách sản phẩm
                        ...items.map((item) => ListTile(
                          title: Text(item["name"] ?? ""),
                          subtitle: Text(
                            "${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(item["price"])} x ${item["quantity"]}",
                          ),
                          trailing: Text(
                            NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                                .format(item["price"] * item["quantity"]),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),

                        const Divider(height: 32),

                        // ⚡ Tổng cộng
                        Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Chiết khấu: 0"),
                              Text("Thuế: 0"),
                              Text("Khách trả: ${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(invoice["paid"])}"),
                              Text("Khách nợ: ${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(invoice["debt"] ?? 0)}"),
                              Text(
                                "Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(invoice["total"])}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ⚡ Nút hành động (Xong / In hóa đơn)
                SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: () {
                            Navigator.pop(context, true); // đóng + clear giỏ
                          },
                          child: const Text("Xong"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: () {
                            // ⚡ TODO: Gọi hàm in / xuất PDF
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("In hóa đơn...")),
                            );
                          },
                          child: const Text("In hóa đơn"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
