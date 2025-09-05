import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/product_repository.dart';
import 'add_product_page.dart';
import 'product_edit_page.dart';
import '../../widgets/product_tile.dart';
import '../../widgets/product_card.dart';
import '../../../data/dao/category_dao.dart';
import '../../widgets/product_filter_bar.dart'; // ✅ import widget mới

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _repo = ProductRepository();
  final CategoryDao _categoryDao = CategoryDao();

  List<Product> _products = [];
  List<Product> _filtered = [];
  List<Category> _categories = [];

  String _filter = "all";
  bool _isGrid = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  Future<void> _loadProducts() async {
    final data = await _repo.getAllProducts();
    setState(() {
      _products = data;
      _applyFilter(_filter);
    });
  }

  Future<void> _loadCategories() async {
    final cats = await _categoryDao.getAll();
    setState(() => _categories = cats);
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
      final baseList = _applyCurrentFilter();
      _filtered = query.isEmpty
          ? baseList
          : baseList
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  List<Product> _applyCurrentFilter() {
    if (_filter == "all") return _products;
    return _products.where((p) => p.categoryId?.toString() == _filter).toList();
  }

  void _applyFilter(String value) {
    setState(() {
      _filter = value;
      _filtered = _applyCurrentFilter();
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
          ProductFilterBar(
            searchQuery: "",
            onSearchChanged: _search,
            selectedFilter: _filter,
            categories: _categories,
            onFilterChanged: _applyFilter,
            isGrid: _isGrid,
            onToggle: (val) => setState(() => _isGrid = val),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text("Không có mặt hàng nào."))
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
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final p = _filtered[i];
                return ProductCard(
                    product: p, onTap: () => _openEdit(p));
              },
            )
                : ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final p = _filtered[i];
                return ProductTile(
                  product: p,
                  onTap: () => _openEdit(p),
                  onDelete: () => _deleteProduct(p.id!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
