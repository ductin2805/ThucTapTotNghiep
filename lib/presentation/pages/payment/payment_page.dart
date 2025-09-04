import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/db/app_database.dart';
import '../../pages/invoices/invoice_detail_page.dart';
import '../../../utils/format.dart';
import 'package:intl/intl.dart';
import '../../../providers/cart_provider.dart';

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

    // Lấy thông tin giỏ hàng từ provider
    final cartState = ref.read(cartProvider);

    String method = _tabController.index == 0 ? "cash" : "bank";

    // 1. Lấy số thứ tự lớn nhất hôm nay +1 để tạo code
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT code FROM invoices WHERE createdAt >= ? AND createdAt < ? ORDER BY code DESC LIMIT 1',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    int orderNum = 1;
    if (result.isNotEmpty) {
      final lastCode = result.first['code'] as String;
      final parts = lastCode.split('.');
      if (parts.length == 3) {
        orderNum = int.tryParse(parts[2])! + 1;
      }
    }

    // Tạo code kiểu DH.yyMMdd.0001
    final code = "DH.${DateFormat('yyMMdd').format(today)}.${orderNum.toString().padLeft(4, '0')}";

    // 2. Insert vào bảng invoices
    final invoiceId = await db.insert("invoices", {
      "code": code,
      "createdAt": today.toIso8601String(),
      "customer": cartState.customer?.name ?? "Khách lẻ",
      "total": widget.totalAmount,
      "paid": paidAmount,
      "debt": changeAmount < 0 ? -changeAmount : 0,
      "method": method,
    });

    // 3. Insert chi tiết sản phẩm vào invoice_items
    for (var item in cartItems) {
      await db.insert("invoice_items", {
        "invoice_id": invoiceId,
        "product_id": item["id"],
        "name": item["name"],
        "price": item["price"],
        "quantity": item["quantity"],
      });
    }

    // 4. Insert vào bảng payments
    await db.insert("payments", {
      "total": widget.totalAmount,
      "paid": paidAmount,
      "change": changeAmount >= 0 ? changeAmount : 0,
      "method": method,
      "createdAt": today.toIso8601String(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Thanh toán thành công! Mã hóa đơn: $code")),
    );

    // 5. Mở trang chi tiết hóa đơn
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceDetailPage(
          invoiceId: invoiceId,
          fromPayment: true,
        ),
      ),
    ).then((_) {
      Navigator.pop(context, true); // Trả về true cho CartPage
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thành tiền ${formatCurrency(widget.totalAmount)}"),
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
            formatCurrency(paidAmount), // ✅ format lại
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Tiền thừa: ${formatCurrency(paidAmount - widget.totalAmount)}", // ✅ format lại
            style: TextStyle(
              fontSize: 16,
              color: (paidAmount - widget.totalAmount) < 0 ? Colors.red : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildNumberPad(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
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
