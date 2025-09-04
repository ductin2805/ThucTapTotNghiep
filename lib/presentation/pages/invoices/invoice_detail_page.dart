import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/db/app_database.dart';
import '../../../providers/cart_provider.dart';
import '../home_page.dart';

class InvoiceDetailPage extends ConsumerStatefulWidget {
  final int invoiceId;
  final bool fromPayment; // ✅ thêm cờ để biết có phải từ thanh toán hay không


  const InvoiceDetailPage({
    super.key,
    required this.invoiceId,
    this.fromPayment = false,
  });

  @override
  ConsumerState<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends ConsumerState<InvoiceDetailPage> {
  late Future<Map<String, dynamic>> _futureInvoice;

  @override
  void initState() {
    super.initState();
    _futureInvoice = _loadInvoiceDetail();
  }

  Future<Map<String, dynamic>> _loadInvoiceDetail() async {
    final db = AppDatabase.instance.db;

    final invoiceRows = await db.query(
      "invoices",
      where: "id = ?",
      whereArgs: [widget.invoiceId],
      limit: 1,
    );

    if (invoiceRows.isEmpty) throw Exception("Không tìm thấy hóa đơn");

    final invoice = invoiceRows.first;

    final items = await db.query(
      "invoice_items",
      where: "invoice_id = ?",
      whereArgs: [widget.invoiceId],
    );

    return {"invoice": invoice, "items": items};
  }

  /// ✅ Quay lại trang Bán hàng
  void _goToSalePage() {
    if (widget.fromPayment) {
      // chỉ clear giỏ nếu đi từ PaymentPage
      ref.read(cartProvider.notifier).clearCart();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(initialIndex: 0), // vào tab Bán hàng
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);

    return WillPopScope(
      onWillPop: () async {
        _goToSalePage();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Chi tiết hóa đơn"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goToSalePage,
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
                        Text("Đơn hàng: DH.${invoice["id"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(createdAt)}"),
                        Text("Khách hàng: ${invoice["customer"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Divider(height: 32),

                        // Danh sách sản phẩm
                        ...items.map((item) => ListTile(
                          title: Text(item["name"] ?? ""),
                          subtitle: Text(
                            "${currency.format(item["price"])} x ${item["quantity"]}",
                          ),
                          trailing: Text(
                            currency.format(item["price"] * item["quantity"]),
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
                              const Text("Chiết khấu: 0"),
                              const Text("Thuế: 0"),
                              Text("Khách trả: ${currency.format(invoice["paid"])}"),
                              Text("Khách nợ: ${currency.format(invoice["debt"] ?? 0)}"),
                              Text(
                                "Tổng tiền: ${currency.format(invoice["total"])}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Nút hành động
                SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: _goToSalePage,
                          child: const Text("Xong"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: () {
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
