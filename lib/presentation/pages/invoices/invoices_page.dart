import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/db/app_database.dart';
import '../../pages/invoices/invoice_detail_page.dart';
class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  late Future<List<Map<String, dynamic>>> _futureInvoices;

  @override
  void initState() {
    super.initState();
    _futureInvoices = _loadInvoices();
  }

  Future<List<Map<String, dynamic>>> _loadInvoices() async {
    final db = AppDatabase.instance.db;
    final rows = await db.query(
      "payments",
      orderBy: "createdAt DESC",
    );
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
    NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text(
          "Hóa đơn",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh lọc
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const [
                Text("Tất cả : ",
                    style: TextStyle(fontSize: 16, color: Colors.black87)),
                Text("Hôm nay",
                    style: TextStyle(fontSize: 16, color: Colors.orange)),
                Spacer(),
                Icon(Icons.filter_alt_outlined, color: Colors.black54),
              ],
            ),
          ),

          // Danh sách hóa đơn
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureInvoices,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Lỗi: ${snapshot.error.toString()}"));
                }
                final invoices = snapshot.data ?? [];

                if (invoices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.insert_drive_file_outlined,
                            size: 100, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Hôm nay bạn chưa có hóa đơn nào",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    final createdAt = DateTime.tryParse(
                        invoice["createdAt"] as String? ?? "") ??
                        DateTime.now();

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InvoiceDetailPage(invoiceId: invoice["id"] as int),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black12),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined,
                                color: Colors.teal, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "DH.${DateFormat('yyMMdd').format(createdAt)}.${invoice["id"].toString().padLeft(4, '0')}",
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text("Khách lẻ",
                                          style: TextStyle(fontSize: 14, color: Colors.black87)),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.access_time, size: 14, color: Colors.black54),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat("HH:mm").format(createdAt),
                                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              currencyFormat.format(invoice["total"]),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.black54),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
