import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

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
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text("Báo cáo", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
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

          const SizedBox(height: 12),

          // 2 ô lợi nhuận / doanh thu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildStatCard("Lợi nhuận", "0"),
                _buildStatCard("Doanh thu", "0"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Phần hóa đơn
          _buildSection("Hóa đơn", [
            _buildStatCard("Số hóa đơn", "0"),
            _buildStatCard("Giá trị hóa đơn", "0"),
            _buildStatCard("Tiền thuế", "0"),
            _buildStatCard("Giảm giá", "0"),
            _buildStatCard("Tiền bán", "0"),
            _buildStatCard("Tiền vốn", "0"),
          ]),

          const SizedBox(height: 20),

          // Phần thanh toán
          _buildSection("Thanh toán", [
            _buildStatCard("Tiền mặt", "0"),
            _buildStatCard("Ngân hàng", "0"),
            _buildStatCard("Khách nợ", "0"),
          ]),
        ],
      ),
    );
  }
}
