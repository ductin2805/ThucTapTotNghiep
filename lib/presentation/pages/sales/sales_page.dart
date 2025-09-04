import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/product_tile.dart';
import '../../../providers/product_provider.dart';
import '../../../data/models/product.dart';
import '../cart/cart_page.dart';
import '../../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';

class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  bool _isGrid = false; // trạng thái hiển thị
  String _searchQuery = "";
  String _selectedCategory = "all";

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productListProvider);

    // lọc theo search + category
    final filteredProducts = products.where((p) {
      final matchSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCategory = _selectedCategory == "all" || p.category == _selectedCategory;
      return matchSearch && matchCategory;
    }).toList();

    // lấy list category từ bảng products
    final categories = ["all", ...{for (var p in products) p.category}];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        title: const Text('Bán hàng'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final cartState = ref.watch(cartProvider); // ✅ lấy CartState
              final totalItems = cartState.totalItems;

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
          // search
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Tìm kiếm mặt hàng",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // dropdown + toggle list/grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: categories
                      .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat == "all" ? "Tất cả mặt hàng" : cat),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val ?? "all"),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.view_list_outlined),
                color: !_isGrid ? Colors.blue : Colors.grey,
                onPressed: () => setState(() => _isGrid = false),
              ),
              IconButton(
                icon: const Icon(Icons.grid_view),
                color: _isGrid ? Colors.blue : Colors.grey,
                onPressed: () => setState(() => _isGrid = true),
              ),
            ]),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
              child: Text(
                "Không tìm thấy mặt hàng nào\n\nVui lòng bấm vào tab \"Thêm\" -> \"Mặt hàng\" để thêm mới.\nCó mặt hàng bạn mới có thể bán hàng.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            )
                : _isGrid
                ? GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.9,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, i) {
                final p = filteredProducts[i];
                return ProductCard(
                  product: p,
                  onTap: () => _showAddToCartDialog(p),
                );
              },
            )
                : ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, i) {
                final p = filteredProducts[i];
                return ProductTile(
                  product: p,
                  onTap: () => _showAddToCartDialog(p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToCartDialog(Product p) {
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
              // 🔑 kiểm tra số lượng tồn kho
              if (qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Số lượng phải lớn hơn 0")),
                );
                return;
              }
              if (qty > p.stock) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Chỉ còn ${p.stock} sản phẩm trong kho")),
                );
                return;
              }
              if (p.id != null) {
                // thêm vào giỏ
                await ref.read(cartProvider.notifier).addToCart(p.id!, quantity: qty);

                // 🔑 giảm tồn kho
                await ref.read(productListProvider.notifier).decreaseStock(p.id!, qty);

                Navigator.pop(c);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${p.name} x$qty đã thêm vào giỏ.")),
                );
              }
            },
            child: const Text("Thêm"),
          )
        ],
      ),
    );
  }
}
