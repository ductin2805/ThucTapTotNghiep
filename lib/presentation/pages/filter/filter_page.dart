import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  final String initialTime;     // ✅ giá trị filter thời gian ban đầu
  final String initialInvoice;  // ✅ giá trị filter hóa đơn ban đầu

  const FilterPage({
    Key? key,
    this.initialTime = "Hôm nay",      // mặc định
    this.initialInvoice = "Tất cả",    // mặc định
  }) : super(key: key);

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late String _selectedTime;
  late String _selectedInvoice;

  final List<String> timeFilters = [
    "Hôm nay",
    "Hôm qua",
    "Tuần này",
    "Tuần trước",
    "Tháng này",
    "Tháng trước",
    "Khác"
  ];

  final List<String> invoiceFilters = [
    "Tất cả",
    "Chưa thanh toán",
    "Thanh toán một phần",
    "Đã thanh toán",
    "Đã xóa"
  ];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _selectedInvoice = widget.initialInvoice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bộ lọc tìm kiếm"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                "time": _selectedTime,
                "invoice": _selectedInvoice,
              });
            },
            child: const Text(
              "Lọc",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          _buildSection("THỜI GIAN", timeFilters, _selectedTime, (val) {
            setState(() => _selectedTime = val);
          }),
          const Divider(),
          _buildSection("HÓA ĐƠN", invoiceFilters, _selectedInvoice, (val) {
            setState(() => _selectedInvoice = val);
          }),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, List<String> options,
      String selected, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey.shade200,
          padding: const EdgeInsets.all(12),
          child: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        ...options.map((e) => RadioListTile<String>(
          title: Text(e),
          value: e,
          groupValue: selected,
          onChanged: (val) => onChanged(val!),
        )),
      ],
    );
  }
}
