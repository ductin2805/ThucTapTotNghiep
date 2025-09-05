import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/product_provider.dart';
import '../../../data/models/product.dart';
import '../cart/cart_page.dart';
import '../../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_tile.dart';
import '../../widgets/product_filter_bar.dart';
import '../../../data/models/category.dart';
import '../../../data/dao/category_dao.dart';

class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  bool _isGrid = false;
  String _searchQuery = "";
  int _selectedCategoryId = 0;

  final CategoryDao _categoryDao = CategoryDao();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _categoryDao.getAll();
    setState(() {
      _categories = cats; // KHÔNG thêm category "Tất cả" ở đây
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productListProvider);

    // filter products
    final filteredProducts = products.where((p) {
      final matchSearch =
      p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCategory =
          _selectedCategoryId == 0 || (p.categoryId ?? 0) == _selectedCategoryId;
      return matchSearch && matchCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bán hàng"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final cartState = ref.watch(cartProvider);
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
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ProductFilterBar(
            searchQuery: _searchQuery,
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            selectedFilter:
            _selectedCategoryId == 0 ? 'all' : _selectedCategoryId.toString(),
            categories: _categories,
            onFilterChanged: (val) {
              setState(() {
                _selectedCategoryId =
                (val == 'all') ? 0 : int.tryParse(val) ?? 0;
              });
            },
            isGrid: _isGrid,
            onToggle: (val) => setState(() => _isGrid = val),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text("Không tìm thấy mặt hàng nào"))
                : _isGrid
                ? GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
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
              if (qty <= 0) return;
              if (qty > p.stock) return;

              if (p.id != null) {
                await ref
                    .read(cartProvider.notifier)
                    .addToCart(p.id!, quantity: qty);
                await ref
                    .read(productListProvider.notifier)
                    .decreaseStock(p.id!, qty);
                Navigator.pop(c);
              }
            },
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }
}
