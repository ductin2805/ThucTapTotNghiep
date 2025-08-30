import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/cart_provider.dart';
import '../../../data/models/cart_product.dart';
import '../../../providers/product_provider.dart';
import '../../pages/payment/payment_page.dart';
import '../../../utils/format.dart'; // formatCurrency

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CartProduct> cart = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).total;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đơn hàng"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => ref.read(cartProvider.notifier).clearCart(),
          )
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text("Đơn hàng"),
            subtitle: Text("DH.${DateTime.now().millisecondsSinceEpoch}"),
          ),
          ListTile(
            title: const Text("Khách hàng"),
            subtitle: const Text("Khách lẻ"),
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
                  subtitle: Text(
                    "${formatCurrency(item.product.price)} x ${item.quantity}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // nút trừ
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () async {
                          if (item.quantity > 1) {
                            // Giảm trong giỏ
                            await ref.read(cartProvider.notifier)
                                .updateQuantity(item.id!, item.quantity - 1);

                            // Tăng lại tồn kho
                            await ref.read(productListProvider.notifier)
                                .updateStock(item.product.id!, item.product.stock + 1);
                          } else {
                            // Xóa khỏi giỏ
                            await ref.read(cartProvider.notifier).removeFromCart(item.id!);

                            // Trả hàng về tồn kho
                            await ref.read(productListProvider.notifier)
                                .updateStock(item.product.id!, item.product.stock + 1);
                          }
                        },
                      ),

                      Text("${item.quantity}"),

                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () async {
                          if (item.product.stock > 0) {
                            // Tăng trong giỏ
                            await ref.read(cartProvider.notifier)
                                .updateQuantity(item.id!, item.quantity + 1);

                            // Giảm tồn kho
                            await ref.read(productListProvider.notifier)
                                .updateStock(item.product.id!, item.product.stock - 1);
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
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  if (cart.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Giỏ hàng trống, không thể thanh toán")),
                    );
                    return;
                  }

                  // ⚡ Truyền cartItems sang PaymentPage
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
                        cartItems: cartItems, // ✅ truyền sang
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
