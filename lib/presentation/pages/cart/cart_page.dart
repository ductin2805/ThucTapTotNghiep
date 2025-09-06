import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/product_provider.dart';
import '../../pages/payment/payment_page.dart';
import '../../../utils/format.dart';
import 'select_customer_page.dart';
import 'package:intl/intl.dart';
import '../../../data/db/app_database.dart';
import '../../../data/models/amount_value.dart';



class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  // Lấy số thứ tự đơn hàng hôm nay từ DB +1
  Future<int> getOrderNumberFromDb() async {
    final db = AppDatabase.instance.db;

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

    return orderNum;
  }

  // Dialog nhập số tiền hoặc %
  Future<void> _showInputDialog(
      BuildContext context,
      String title,
      void Function(AmountValue value) onConfirm,
      ) async {
    String selectedType = "Tiền mặt";
    String inputValue = "0";

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(title, textAlign: TextAlign.center),
            content: SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Chọn loại nhập ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("Tiền mặt"),
                        selected: selectedType == "Tiền mặt",
                        onSelected: (_) => setState(() {
                          selectedType = "Tiền mặt";
                          inputValue = "0";
                        }),
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text("%"),
                        selected: selectedType == "%",
                        onSelected: (_) => setState(() {
                          selectedType = "%";
                          inputValue = "0";
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),

                  // --- Hiển thị giá trị nhập ---
                  Text(
                    selectedType == "Tiền mặt"
                        ? formatCurrency(double.tryParse(inputValue) ?? 0)
                        : "$inputValue %",
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // --- Bàn phím số ---
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ...[
                        '1',
                        '2',
                        '3',
                        '4',
                        '5',
                        '6',
                        '7',
                        '8',
                        '9',
                        '000',
                        '0',
                        '⌫'
                      ].map((text) {
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (text == '⌫') {
                                if (inputValue.isNotEmpty) {
                                  inputValue =
                                      inputValue.substring(0, inputValue.length - 1);
                                  if (inputValue.isEmpty) inputValue = '0';
                                }
                              } else {
                                if (inputValue == '0') {
                                  inputValue = text;
                                } else {
                                  inputValue += text;
                                }
                              }
                            });
                          },
                          child:
                          Text(text, style: const TextStyle(fontSize: 18)),
                        );
                      })
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () {
                  final value = double.tryParse(inputValue) ?? 0;
                  onConfirm(AmountValue(value, selectedType));
                  Navigator.pop(context);
                },
                child: const Text("Xác nhận"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Hàm tạo mã đơn hàng kiểu DH.yyMMdd.0001
  String generateOrderId(int orderNumber) {
    final now = DateTime.now();
    final datePart = DateFormat('yyMMdd').format(now);
    final numPart = orderNumber.toString().padLeft(4, '0');
    return "DH.$datePart.$numPart";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cart = cartState.items;
    final total = cartState.total;
    final customer = cartState.customer;

    // Watch các provider đã khai báo trong cart_provider.dart
    final discountValue = ref.watch(discountProvider);
    final surchargeValue = ref.watch(surchargeProvider);
    final taxValue = ref.watch(taxProvider);
    final noteValue = ref.watch(noteProvider);
    final finalTotal = calculateFinalTotal(
      baseTotal: total,
      discount: discountValue,
      surcharge: surchargeValue,
      tax: taxValue,
    );

    return FutureBuilder<int>(
      future: getOrderNumberFromDb(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Lỗi: ${snapshot.error}")),
          );
        }

        final orderNum = snapshot.data ?? 1;
        final orderId = generateOrderId(orderNum);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Đơn hàng"),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                tooltip: customer?.name ?? "Khách hàng",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SelectCustomerPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  for (final item in cart) {
                    final product = await ref
                        .read(productListProvider.notifier)
                        .getById(item.product.id!);
                    if (product != null) {
                      await ref
                          .read(productListProvider.notifier)
                          .updateStock(product.id!, product.stock + item.quantity);
                    }
                  }
                  ref.read(cartProvider.notifier).clearCart();
                },
              )
            ],
          ),
          body: Column(
            children: [
              ListTile(
                title: const Text("Đơn hàng"),
                subtitle: Text(orderId),
              ),
              ListTile(
                title: const Text("Khách hàng"),
                subtitle: Text(customer?.name ?? "Khách lẻ"),
              ),
              const Divider(),
              Expanded(
                child: cart.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.assignment_outlined,
                          size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        "Đơn hàng của bạn chưa có mặt hàng nào",
                        style: TextStyle(color: Colors.black54),
                      )
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (context, i) {
                    final item = cart[i];
                    return ListTile(
                      title: Text(item.product.name),
                      subtitle: Text(
                          "${formatCurrency(item.product.price)} x ${item.quantity}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon:
                            const Icon(Icons.remove_circle_outline),
                            onPressed: () async {
                              final product = await ref
                                  .read(productListProvider.notifier)
                                  .getById(item.product.id!);
                              if (product != null) {
                                if (item.quantity > 1) {
                                  await ref
                                      .read(productListProvider.notifier)
                                      .updateStock(product.id!,
                                      product.stock + 1);
                                  await ref
                                      .read(cartProvider.notifier)
                                      .updateQuantity(
                                      item.id!, item.quantity - 1);
                                } else {
                                  await ref
                                      .read(cartProvider.notifier)
                                      .removeFromCart(item.id!);
                                  await ref
                                      .read(productListProvider.notifier)
                                      .updateStock(product.id!,
                                      product.stock + 1);
                                }
                              }
                            },
                          ),
                          Text("${item.quantity}"),
                          IconButton(
                            icon:
                            const Icon(Icons.add_circle_outline),
                            onPressed: () async {
                              final product = await ref
                                  .read(productListProvider.notifier)
                                  .getById(item.product.id!);
                              if (product != null && product.stock > 0) {
                                await ref
                                    .read(productListProvider.notifier)
                                    .updateStock(product.id!,
                                    product.stock - 1);
                                await ref
                                    .read(cartProvider.notifier)
                                    .updateQuantity(
                                    item.id!, item.quantity + 1);
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text("Hết hàng trong kho")),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Column(
                children: [
                  _buildSummaryButton(
                      context, ref, "Chiết khấu", discountValue, (val) {
                    ref.read(discountProvider.notifier).state = val;
                  }),
                  _buildSummaryButton(
                      context, ref, "Phụ phí", surchargeValue, (val) {
                    ref.read(surchargeProvider.notifier).state = val;
                  }),
                  _buildSummaryButton(context, ref, "Thuế", taxValue, (val) {
                    ref.read(taxProvider.notifier).state = val;
                  }),
                  _buildSummaryButton(
                      context, ref, "Ghi chú", noteValue, (val) {
                    ref.read(noteProvider.notifier).state = val;
                  }),
                  _buildSummaryRow("Tổng tiền", formatCurrency(finalTotal), bold: true),
                ],
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      if (cart.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                              Text("Giỏ hàng trống, không thể thanh toán")),
                        );
                        return;
                      }

                      final cartItems = cart
                          .map((c) => {
                        "id": c.product.id,
                        "name": c.product.name,
                        "price": c.product.price,
                        "quantity": c.quantity,
                      })
                          .toList();

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentPage(
                            totalAmount: finalTotal,
                            cartItems: cartItems,
                          ),
                        ),
                      );

                      if (result == true) {
                        ref.read(cartProvider.notifier).clearCart();
                      }
                    },
                    child: const Text("Thanh toán"),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSummaryButton(
      BuildContext context,
      WidgetRef ref,
      String label,
      dynamic value, // AmountValue hoặc String
      Function(dynamic) onChanged,
      ) {
    String displayValue;
    if (value is AmountValue) {
      displayValue = displayAmount(value);
    } else {
      displayValue = value.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Row(
            children: [
              Text(
                displayValue,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                onPressed: () {
                  if (value is AmountValue) {
                    _showInputDialog(context, label, (newValue) {
                      onChanged(newValue);
                      print(
                          "[$label] nhập ${newValue.value} (${newValue.type})");
                    });
                  } else if (value is String) {
                    final controller = TextEditingController(text: value);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(label),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Hủy"),
                          ),
                          TextButton(
                            onPressed: () {
                              onChanged(controller.text);
                              Navigator.pop(context);
                            },
                            child: const Text("Xác nhận"),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
