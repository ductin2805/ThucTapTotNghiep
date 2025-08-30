import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/db/app_database.dart';
import '../../pages/invoices/invoice_detail_page.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;


  const PaymentPage({
    super.key,
    required this.totalAmount,
    required this.cartItems,
  });

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

  Future<void> _savePayment(List<Map<String, dynamic>> cartItems) async {
    final db = AppDatabase.instance.db;

    String method = _tabController.index == 0 ? "cash" : "bank";

    // 1. Insert vào bảng invoices
    final invoiceId = await db.insert("invoices", {
      "code": "HD${DateTime.now().millisecondsSinceEpoch}", // sinh code đơn giản
      "createdAt": DateTime.now().toIso8601String(),
      "customer": "Khách lẻ", // hoặc lấy từ input
      "total": widget.totalAmount,
      "paid": paidAmount,
      "debt": changeAmount < 0 ? -changeAmount : 0,
      "method": method,
    });

    // 2. Insert chi tiết sản phẩm vào invoice_items
    for (var item in cartItems) {
      await db.insert("invoice_items", {
        "invoice_id": invoiceId,
        "product_id": item["id"], // hoặc productId
        "name": item["name"],
        "price": item["price"],
        "quantity": item["quantity"],
      });
    }

    // 3. (Tuỳ chọn) Insert vào bảng payments để lưu lịch sử thanh toán
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

    // 4. Sau khi thanh toán thì mở hóa đơn chi tiết
    // 👉 Khi đóng InvoiceDetailPage thì trả true về CartPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceDetailPage(invoiceId: invoiceId),
      ),
    ).then((_) {
      Navigator.pop(context, true); // Trả về true cho CartPage
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
              onPressed: () => _savePayment(widget.cartItems),
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
