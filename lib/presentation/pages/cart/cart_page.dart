import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../data/models/cart_product.dart';
import '../../pages/payment/payment_page.dart';
import '../../../utils/format.dart';
import 'select_customer_page.dart';
import 'package:intl/intl.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  // Hàm tạo mã đơn hàng
  String generateOrderId(int orderNumber) {
    final now = DateTime.now();
    final y = now.year % 100;        // 2 số cuối của năm
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final datePart = "$y$m$d";

    // orderNumber chạy tăng dần trong ngày
    final numPart = orderNumber.toString().padLeft(4, '0');

    return "DH.$datePart.$numPart";
  }

  // Lấy số thứ tự đơn hàng hôm nay dựa trên cart hoặc DB
  int getOrderNumber(List<CartProduct> cart) {
    // Ví dụ đơn giản: dùng số lượng sản phẩm trong giỏ +1
    return cart.length + 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cart = cartState.items;
    final total = cartState.total;
    final customer = cartState.customer;

    // Tạo mã đơn hàng tự động
    final orderNumber = getOrderNumber(cart);
    final orderId = generateOrderId(orderNumber);

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
                MaterialPageRoute(builder: (_) => const SelectCustomerPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final cart = ref.read(cartProvider).items;
              for (final item in cart) {
                final product = await ref.read(productListProvider.notifier).getById(item.product.id!);
                if (product != null) {
                  await ref.read(productListProvider.notifier)
                      .updateStock(product.id!, product.stock + item.quantity);
                  await ref.read(productListProvider.notifier).reloadStock(product.id!);
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
            subtitle: Text(orderId), // dùng mã đơn hàng tăng dần
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
                  Icon(Icons.assignment_outlined, size: 60, color: Colors.grey),
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
                  subtitle: Text("${formatCurrency(item.product.price)} x ${item.quantity}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () async {
                          final product = await ref.read(productListProvider.notifier).getById(item.product.id!);
                          if (product != null) {
                            if (item.quantity > 1) {
                              await ref.read(productListProvider.notifier)
                                  .updateStock(product.id!, product.stock + 1);
                              await ref.read(cartProvider.notifier)
                                  .updateQuantity(item.id!, item.quantity - 1);
                              await ref.read(productListProvider.notifier).reloadStock(product.id!);
                            } else {
                              await ref.read(cartProvider.notifier).removeFromCart(item.id!);
                              await ref.read(productListProvider.notifier)
                                  .updateStock(product.id!, product.stock + 1);
                              await ref.read(productListProvider.notifier).reloadStock(product.id!);
                            }
                          }
                        },
                      ),
                      Text("${item.quantity}"),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () async {
                          final product = await ref.read(productListProvider.notifier).getById(item.product.id!);
                          if (product != null && product.stock > 0) {
                            await ref.read(productListProvider.notifier)
                                .updateStock(product.id!, product.stock - 1);
                            await ref.read(cartProvider.notifier)
                                .updateQuantity(item.id!, item.quantity + 1);
                            await ref.read(productListProvider.notifier).reloadStock(product.id!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Hết hàng trong kho")),
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
              _buildSummaryRow("Chiết khấu", "0"),
              _buildSummaryRow("Phụ phí", "0"),
              _buildSummaryRow("Ghi chú", "0"),
              _buildSummaryRow("Thuế", "0"),
              _buildSummaryRow("Tổng tiền", formatCurrency(total), bold: true),
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
                      const SnackBar(content: Text("Giỏ hàng trống, không thể thanh toán")),
                    );
                    return;
                  }

                  final cartItems = cart.map((c) => {
                    "id": c.product.id,
                    "name": c.product.name,
                    "price": c.product.price,
                    "quantity": c.quantity,
                  }).toList();

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentPage(
                        totalAmount: total,
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
}
