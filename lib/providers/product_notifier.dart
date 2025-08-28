import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';
import '../data/dao/product_dao.dart';

class ProductNotifier extends StateNotifier<List<Product>> {
  final ProductDao _dao = ProductDao();

  ProductNotifier() : super([]) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = await _dao.getAll();
  }

  Future<void> addProduct(Product product) async {
    await _dao.insert(product);
    await loadProducts();
  }

  Future<void> updateStock(int id, int newStock) async {
    await _dao.updateStock(id, newStock);
    await loadProducts();
  }

  Future<void> delete(int id) async {
    await _dao.delete(id);
    await loadProducts();
  }
}

final productListProvider =
StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});
