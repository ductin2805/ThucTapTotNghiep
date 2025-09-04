import 'package:flutter/material.dart';
import 'package:thuc_tap_tot_nghiep/presentation/pages/more/product_list_page.dart';
import 'account_page.dart';
import 'customer_list_page.dart';
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  Widget _buildMenuItem(IconData icon, String title,
      {Color color = Colors.black87, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
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
        title: const Text("Thông tin", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          _buildMenuItem(
            Icons.person_outline,
            "Tài khoản",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountPage()),
              );
            },
          ),
          _buildMenuItem(
            Icons.inventory_2_outlined,
            "Mặt hàng",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductListPage()),
              );
            },
          ),
          _buildMenuItem(Icons.folder_outlined, "Danh mục"),
          _buildMenuItem(Icons.speed_outlined, "Đơn vị tính"),
          _buildMenuItem(
            Icons.people_outline,
            "Khách hàng",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CustomerListPage()),
              );
            },
          ),
          _buildMenuItem(Icons.local_shipping_outlined, "Nhà cung cấp"),
          _buildMenuItem(Icons.print_outlined, "Máy in", color: Colors.red),

          const Divider(thickness: 8, color: Color(0xFFF2F2F2)),

          _buildMenuItem(Icons.pie_chart_outline, "Báo cáo tổng hợp"),
          _buildMenuItem(Icons.add_box_outlined, "Nhập hàng"),
          _buildMenuItem(Icons.settings_outlined, "Cài đặt"),
        ],
      ),
    );
  }
}
