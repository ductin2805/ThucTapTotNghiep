import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/product_tile.dart';
import '../../../providers/product_provider.dart';
import '../../../data/models/product.dart';
import '../more/add_product_page.dart';

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
          IconButton(onPressed: () {}, icon: const Icon(Icons.qr_code_scanner)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Mở form thêm sản phẩm
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage()));
          // khi trở về, provider đã reload trong AddProductPage
        },
        child: const Icon(Icons.add),
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
                    // dialog cập nhật tồn (ví dụ)
                    showDialog(
                      context: context,
                      builder: (c) {
                        final controller = TextEditingController(text: p.stock.toString());
                        return AlertDialog(
                          title: Text('Cập nhật tồn: ${p.name}'),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Số lượng'),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Hủy')),
                            ElevatedButton(
                                onPressed: () async {
                                  final newStock = int.tryParse(controller.text) ?? p.stock;
                                  await ref.read(productListProvider.notifier).updateStock(p.id!, newStock);
                                  Navigator.pop(c);
                                },
                                child: const Text('Lưu')),
                          ],
                        );
                      },
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
