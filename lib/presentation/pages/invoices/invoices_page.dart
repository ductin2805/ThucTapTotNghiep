import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/db/app_database.dart';
import '../../pages/invoices/invoice_detail_page.dart';
import '../filter/filter_page.dart';
import '../../../utils/format.dart';
import '../../widgets/app_drawer.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  String selectedTime = "Hôm nay";
  String selectedInvoice = "Tất cả";


  late Future<List<Map<String, dynamic>>> _futureInvoices;

  @override
  void initState() {
    super.initState();
    _futureInvoices = _loadInvoices();
  }

  List<DateTime>? _getDateRange(String timeFilter) {
    final now = DateTime.now();
    switch (timeFilter) {
      case "Hôm nay":
        return [DateTime(now.year, now.month, now.day), DateTime(now.year, now.month, now.day + 1)];
      case "Hôm qua":
        return [DateTime(now.year, now.month, now.day - 1), DateTime(now.year, now.month, now.day)];
      case "Tuần này":
        final start = now.subtract(Duration(days: now.weekday - 1));
        return [start, start.add(const Duration(days: 7))];
      case "Tuần trước":
        final end = now.subtract(Duration(days: now.weekday));
        return [end.subtract(const Duration(days: 7)), end];
      case "Tháng này":
        return [DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 1)];
      case "Tháng trước":
        return [DateTime(now.year, now.month - 1, 1), DateTime(now.year, now.month, 1)];
      default:
        return null;
    }
  }

  Future<List<Map<String, dynamic>>> _loadInvoices() async {
    final db = AppDatabase.instance.db;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    final range = _getDateRange(selectedTime);
    if (range != null) {
      whereClauses.add("i.createdAt >= ? AND i.createdAt < ?");
      whereArgs.add(range[0].toIso8601String());
      whereArgs.add(range[1].toIso8601String());
    }

    if (selectedInvoice != "Tất cả") {
      whereClauses.add("i.method = ?");
      whereArgs.add(selectedInvoice);
    }

    final whereString =
    whereClauses.isEmpty ? "" : "WHERE ${whereClauses.join(" AND ")}";

    final sql = '''
    SELECT 
      i.id,
      i.code,
      i.createdAt,
      COALESCE(c.name, i.customer) AS customerName,
      i.total,
      i.paid,
      i.debt,
      i.method,
      GROUP_CONCAT(it.name || ' x' || it.quantity, ', ') AS items
    FROM invoices i
    LEFT JOIN customers c ON i.customer = c.id
    LEFT JOIN invoice_items it ON i.id = it.invoice_id
    $whereString
    GROUP BY i.id
    ORDER BY i.createdAt DESC
  ''';
    return await db.rawQuery(sql, whereArgs);
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
        _futureInvoices = _loadInvoices();
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // ✅ mở Drawer
            },
          ),
        ),
        title: const Text("Hóa đơn", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _openFilter),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Thanh lọc
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text("$selectedInvoice : ", style: const TextStyle(fontSize: 16)),
                GestureDetector(
                  onTap: _openFilter,
                  child: Text(selectedTime, style: const TextStyle(fontSize: 16, color: Colors.orange)),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined, color: Colors.black54),
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
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                }

                final invoices = snapshot.data ?? [];

                if (invoices.isEmpty) {
                  return const Center(
                    child: Text(
                      "Không có hóa đơn nào",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                // Console log để xem mã hóa đơn và thông tin
                for (var invoice in invoices) {
                  final createdAt = DateTime.tryParse(invoice['createdAt'] ?? '') ?? DateTime.now();
                  final code = invoice['code'] ??
                      "DH.${DateFormat('yyMMdd').format(createdAt)}.${(invoice['id'] ?? 0).toString().padLeft(4, '0')}";

                  print("Invoice ID: ${invoice['id']}, Code: $code, Customer: ${invoice['customerName']}, Total: ${invoice['total']}");
                }

                return ListView.builder(
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    final createdAt = DateTime.tryParse(invoice["createdAt"] ?? "") ?? DateTime.now();
                    final customerName = invoice["customerName"] ?? "Khách lẻ";

                    return ListTile(
                      leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.teal, size: 32),
                      title: Text(
                        "DH.${DateFormat('yyMMdd').format(createdAt)}.${(invoice["id"] ?? 0).toString().padLeft(4, '0')}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(DateFormat("HH:mm").format(createdAt), style: const TextStyle(fontSize: 13, color: Colors.black54)),
                          const SizedBox(width: 12),
                          Text(customerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(formatCurrency(invoice["total"] ?? 0),
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          const Icon(Icons.chevron_right, color: Colors.black54),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => InvoiceDetailPage(invoiceId: invoice["id"] as int)),
                        );
                      },
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
