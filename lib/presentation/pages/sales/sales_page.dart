import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/product_tile.dart';
import '../../../providers/product_provider.dart';
import '../../../data/models/product.dart';
import '../more/add_product_page.dart';
import '../cart/cart_page.dart';
import '../../../providers/cart_provider.dart';
import '../../../utils/format.dart';

class SalesPage extends ConsumerWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        title: const Text('Bán hàng'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final cart = ref.watch(cartProvider);
              final totalItems = cart.fold<int>(0, (sum, item) => sum + item.quantity);

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartPage()),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart),
                  ),
                  if (totalItems > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "$totalItems",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: Column(
        children: [
          // search simple
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Tìm kiếm mặt hàng",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // dropdown + list/grid icons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: 'all',
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('Tất cả mặt hàng'),
                    ),
                    DropdownMenuItem(
                      value: 'default',
                      child: Text('Mặc định'),
                    ),
                    DropdownMenuItem(
                      value: 'favorite',
                      child: Text('Yêu thích'),
                    ),
                  ],
                  onChanged: (_) {},
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: () {}, icon: const Icon(Icons.view_list_outlined)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.grid_view)),
            ]),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: products.isEmpty
                ? const Center(
              child: Text(
                "Không tìm thấy mặt hàng nào\n\nVui lòng bấm vào tab \"Thêm\" -> \"Mặt hàng\" để thêm mới.\nCó mặt hàng bạn mới có thể bán hàng.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            )
                : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, i) {
                final p = products[i];
                return ProductTile(
                  product: p,
                  onTap: () {
                    final controller = TextEditingController(text: "1");
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text("Thêm vào giỏ: ${p.name}"),
                        content: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Số lượng"),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text("Hủy"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final qty = int.tryParse(controller.text) ?? 1;
                              if (p.id != null) {
                                // 1. Thêm vào giỏ hàng
                                await ref.read(cartProvider.notifier).addToCart(p.id!, quantity: qty);

                                // 2. Giảm số lượng tồn kho của sản phẩm
                                final newStock = (p.stock - qty).clamp(0, p.stock); // không cho nhỏ hơn 0
                                await ref.read(productListProvider.notifier).updateStock(p.id!, newStock);

                                // 3. Đóng dialog
                                Navigator.pop(c);

                                // 4. Hiện thông báo
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("${p.name} x$qty đã thêm vào giỏ. Tồn mới: $newStock")),
                                );
                              }
                            },
                            child: const Text("Thêm"),
                          ),
                        ],
                      ),
                    );
                  },
                  onDelete: () async {
                    if (p.id != null) {
                      await ref.read(productListProvider.notifier).delete(p.id!);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
