import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/db/app_database.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final double totalAmount;

  const PaymentPage({super.key, required this.totalAmount});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String inputAmount = "";
  double paidAmount = 0;
  double changeAmount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _onKeyTap(String value) {
    setState(() {
      if (value == "DEL") {
        if (inputAmount.isNotEmpty) {
          inputAmount = inputAmount.substring(0, inputAmount.length - 1);
        }
      } else {
        inputAmount += value;
      }
      paidAmount = double.tryParse(inputAmount) ?? 0;
      changeAmount = paidAmount - widget.totalAmount;
    });
  }

  Future<void> _savePayment() async {
    final db = AppDatabase.instance.db;

    String method = _tabController.index == 0 ? "cash" : "bank";

    // Lưu thanh toán
    await db.insert("payments", {
      "total": widget.totalAmount,
      "paid": paidAmount,
      "change": changeAmount >= 0 ? changeAmount : 0,
      "method": method,
      "createdAt": DateTime.now().toIso8601String(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thanh toán thành công")),
    );

    // ⚡ Đợi hết frame hiện tại rồi mới pop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop(true); // trả kết quả về CartPage
      }
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thành tiền ${widget.totalAmount.toStringAsFixed(0)}"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Tiền mặt"),
            Tab(text: "Ngân hàng"),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text("Khách trả :", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            paidAmount.toStringAsFixed(0),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Tiền thừa: ${(paidAmount - widget.totalAmount) >= 0
                ? (paidAmount - widget.totalAmount).toStringAsFixed(0)
                : "0"}",
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const Spacer(),
          _buildNumberPad(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _savePayment,
              child: const Text("Thanh toán"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPad() {
    final keys = [
      "1","2","3",
      "4","5","6",
      "7","8","9",
      "000","0","DEL",
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];
        return InkWell(
          onTap: () => _onKeyTap(key),
          child: Center(
            child: key == "DEL"
                ? const Icon(Icons.backspace_outlined)
                : Text(
              key,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        );
      },
    );
  }
}
