import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product.dart';
import '../data/dao/product_dao.dart';


class ProductNotifier extends StateNotifier<List<Product>> {
  final ProductDao _dao = ProductDao();

  ProductNotifier() : super([]) {
    loadProducts();
  }

  /// Load toàn bộ sản phẩm
  Future<void> loadProducts() async {
    state = await _dao.getAll();
  }

  /// Thêm sản phẩm mới
  Future<void> addProduct(Product product) async {
    await _dao.insert(product);
    await loadProducts();
  }

  /// Cập nhật tồn kho theo ID
  Future<void> updateStock(int id, int newStock) async {
    await _dao.updateStock(id, newStock);
    // Chỉ cập nhật lại state thay vì load toàn bộ
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(stock: newStock) else p,
    ];
  }

  /// Lấy tồn kho hiện tại của sản phẩm theo ID
  int? getStockById(int id) {
    try {
      return state.firstWhere((p) => p.id == id).stock;
    } catch (_) {
      return null;
    }
  }

  /// Xóa sản phẩm
  Future<void> delete(int id) async {
    await _dao.delete(id);
    state = state.where((p) => p.id != id).toList();
  }
}

final productListProvider =
StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});
