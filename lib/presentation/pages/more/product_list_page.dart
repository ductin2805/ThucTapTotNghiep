import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import 'add_product_page.dart';
import 'product_edit_page.dart';
import '../../widgets/product_tile.dart';
import '../../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _repo = ProductRepository();
  List<Product> _products = [];
  List<Product> _filtered = [];
  String _filter = "all";
  bool _isGrid = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await _repo.getAllProducts();
    setState(() {
      _products = data;
      _filtered = data;
    });
  }

  void _deleteProduct(int id) async {
    await _repo.deleteProduct(id);
    _loadProducts();
  }

  void _openEdit(Product? product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductEditPage(product: product)),
    );
    _loadProducts();
  }

  void _openAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddProductPage()),
    );
    _loadProducts();
  }

  void _search(String query) {
    setState(() {
      _filtered = query.isEmpty
          ? _products
          : _products
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _applyFilter(String value) {
    setState(() {
      _filter = value;
      _filtered = (value == "favorite")
          ? _products.where((p) => p.isFavorite == true).toList()
          : _products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thiết lập mặt hàng"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () {}),
          IconButton(icon: const Icon(Icons.add), onPressed: _openAdd),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(onChanged: _search),
          _FilterAndToggleBar(
            filter: _filter,
            isGrid: _isGrid,
            onFilterChanged: _applyFilter,
            onToggle: (isGrid) => setState(() => _isGrid = isGrid),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _filtered.isEmpty
                ? const _EmptyListView()
                : _isGrid
                ? ProductGrid(
              products: _filtered,
              onEdit: _openEdit,
              onDelete: _deleteProduct,
            )
                : ProductList(
              products: _filtered,
              onEdit: _openEdit,
              onDelete: _deleteProduct,
            ),
          ),
        ],
      ),
    );
  }
}

/// ----------------- Widgets tái sử dụng -----------------
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: "Tìm kiếm mặt hàng",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _FilterAndToggleBar extends StatelessWidget {
  final String filter;
  final bool isGrid;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<bool> onToggle;

  const _FilterAndToggleBar({
    required this.filter,
    required this.isGrid,
    required this.onFilterChanged,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: filter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tất cả mặt hàng')),
                DropdownMenuItem(value: 'default', child: Text('Mặc định')),
                DropdownMenuItem(value: 'favorite', child: Text('Yêu thích')),
              ],
              onChanged: (v) => onFilterChanged(v!),
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.view_list_outlined),
            color: !isGrid ? Colors.blue : Colors.grey,
            onPressed: () => onToggle(false),
          ),
          IconButton(
            icon: const Icon(Icons.grid_view),
            color: isGrid ? Colors.blue : Colors.grey,
            onPressed: () => onToggle(true),
          ),
        ],
      ),
    );
  }
}

class _EmptyListView extends StatelessWidget {
  const _EmptyListView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Không có mặt hàng nào.\nVui lòng thêm mới.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black54),
      ),
    );
  }
}

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onEdit;
  final Function(int) onDelete;

  const ProductGrid({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.9,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final p = products[i];
        return ProductCard(product: p, onTap: () => onEdit(p));
      },
    );
  }
}

class ProductList extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onEdit;
  final Function(int) onDelete;

  const ProductList({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, i) {
        final p = products[i];
        return ProductTile(
          product: p,
          onTap: () => onEdit(p),
          onDelete: () => onDelete(p.id!),
        );
      },
    );
  }
}
