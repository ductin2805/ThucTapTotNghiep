import 'package:flutter/material.dart';
import 'sales/sales_page.dart';
import 'invoices/invoices_page.dart';
import 'reports/reports_page.dart';
import 'more/more_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selected = 0;
  final pages = const [
    SalesPage(),
    InvoicesPage(),
    ReportsPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selected],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selected,
        onTap: (i) => setState(() => _selected = i),
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Bán hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Hóa đơn'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Báo cáo'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'Thêm'),
        ],
      ),
    );
  }
}
