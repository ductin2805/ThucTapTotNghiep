import 'package:flutter/material.dart';
import '../../../utils/format.dart';
import '../../../data/db/app_database.dart';
import '../../../data/models/report_summary.dart';
import '../filter/filter_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  ReportSummary? summary; // dữ liệu báo cáo

  // biến lưu filter
  String selectedTime = "Hôm nay";
  String selectedInvoice = "Tất cả";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = AppDatabase.instance;

    // chỉ cần 1 hàm duy nhất
    final data = await db.getReportByFilter(selectedTime, selectedInvoice);

    setState(() => summary = data);
  }

  Widget _buildStatCard(String title, String value,
      {Color color = Colors.black87}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: children,
          ),
        ],
      ),
    );
  }

  Future<void> _openFilter() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FilterPage()),
    );

    if (result != null && mounted) {
      setState(() {
        selectedTime = result["time"];
        selectedInvoice = result["invoice"];
      });

      // gọi lại load data
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (summary == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title:
        const Text("Báo cáo", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilter,
          ),
        ],
      ),
      body: ListView(
        children: [
          // Thanh lọc
          Container(
            width: double.infinity,
            color: Colors.white,
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  "$selectedInvoice : ",
                  style:
                  const TextStyle(fontSize: 16, color: Colors.black87),
                ),

                // chữ thời gian có thể bấm
                GestureDetector(
                  onTap: _openFilter,
                  child: Text(
                    selectedTime,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.orange),
                  ),
                ),

                const Spacer(),

                // icon filter
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

          const SizedBox(height: 12),

          // 2 ô lợi nhuận / doanh thu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildStatCard(
                    "Lợi nhuận", formatCurrency(summary!.profit)),
                _buildStatCard(
                    "Doanh thu", formatCurrency(summary!.revenue)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Phần hóa đơn
          _buildSection("Hóa đơn", [
            _buildStatCard("Số hóa đơn", "${summary!.invoiceCount}"),
            _buildStatCard("Giá trị hóa đơn",
                formatCurrency(summary!.invoiceValue)),
            _buildStatCard("Tiền thuế", formatCurrency(summary!.tax)),
            _buildStatCard("Giảm giá", formatCurrency(summary!.discount)),
            _buildStatCard("Tiền bán", formatCurrency(summary!.revenue)),
            _buildStatCard("Tiền vốn", formatCurrency(summary!.cost)),
          ]),

          const SizedBox(height: 20),

          // Phần thanh toán
          _buildSection("Thanh toán", [
            _buildStatCard("Tiền mặt", formatCurrency(summary!.cash)),
            _buildStatCard("Ngân hàng", formatCurrency(summary!.bank)),
            _buildStatCard("Khách nợ", formatCurrency(summary!.debt)),
          ]),
        ],
      ),
    );
  }
}
