import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/db/app_database.dart';
import '../../pages/invoices/invoice_detail_page.dart';
import '../filter/filter_page.dart'; // ✅ thêm filter page

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  // biến lưu filter
  String selectedTime = "Hôm nay";
  String selectedInvoice = "Tất cả";

  late Future<List<Map<String, dynamic>>> _futureInvoices;

  @override
  void initState() {
    super.initState();
    _futureInvoices = _loadInvoices();
  }

  /// ✅ Hàm hỗ trợ: trả về [start, end] theo filter thời gian
  List<DateTime>? _getDateRange(String timeFilter) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (timeFilter) {
      case "Hôm nay":
        start = DateTime(now.year, now.month, now.day);
        end = start.add(const Duration(days: 1));
        break;
      case "Hôm qua":
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
        end = DateTime(now.year, now.month, now.day);
        break;
      case "Tuần này":
        start = now.subtract(Duration(days: now.weekday - 1));
        end = start.add(const Duration(days: 7));
        break;
      case "Tuần trước":
        end = now.subtract(Duration(days: now.weekday));
        start = end.subtract(const Duration(days: 7));
        break;
      case "Tháng này":
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1);
        break;
      case "Tháng trước":
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 1);
        break;
      default:
        return null; // "Khác" => chưa làm
    }
    return [start, end];
  }

  Future<List<Map<String, dynamic>>> _loadInvoices() async {
    final db = AppDatabase.instance.db;

    // Tạo điều kiện where
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    // lọc theo thời gian
    final range = _getDateRange(selectedTime);
    if (range != null) {
      whereClauses.add("createdAt >= ? AND createdAt < ?");
      whereArgs.add(range[0].toIso8601String());
      whereArgs.add(range[1].toIso8601String());
    }

    // lọc theo trạng thái hóa đơn
    if (selectedInvoice != "Tất cả") {
      whereClauses.add("status = ?");
      whereArgs.add(selectedInvoice);
    }

    final rows = await db.query(
      "payments",
      orderBy: "createdAt DESC",
      where: whereClauses.isEmpty ? null : whereClauses.join(" AND "),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );

    return rows;
  }

  Future<void> _openFilter() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilterPage(
          initialTime: selectedTime,
          initialInvoice: selectedInvoice,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        selectedTime = result["time"];
        selectedInvoice = result["invoice"];
        _futureInvoices = _loadInvoices(); // gọi lại load data theo filter
      });
    }
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
            onPressed: _openFilter, // ✅ mở filter
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
              children: [
                Text(
                  "$selectedInvoice : ",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                GestureDetector(
                  onTap: _openFilter,
                  child: Text(
                    selectedTime,
                    style: const TextStyle(fontSize: 16, color: Colors.orange),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined,
                      color: Colors.black54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _openFilter,
                ),
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
                          "Không có hóa đơn nào",
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
                            builder: (_) => InvoiceDetailPage(
                                invoiceId: invoice["id"] as int),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(invoice["status"] ?? "Không rõ",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87)),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.access_time,
                                          size: 14, color: Colors.black54),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat("HH:mm").format(createdAt),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              currencyFormat.format(invoice["total"] ?? 0),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const Icon(Icons.chevron_right,
                                color: Colors.black54),
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
