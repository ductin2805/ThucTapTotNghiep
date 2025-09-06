import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';
import '../data/dao/product_dao.dart';

// Provider instance của repository (nếu cần có thể đổi impl)
final productRepoProvider = Provider<ProductRepository>((ref) => ProductRepository());

// StateNotifier giữ danh sách sản phẩm
final productListProvider = StateNotifierProvider<ProductListNotifier, List<Product>>((ref) {
  final repo = ref.watch(productRepoProvider);
  return ProductListNotifier(repo);
});

class ProductListNotifier extends StateNotifier<List<Product>> {
  final ProductRepository repo;
  ProductListNotifier(this.repo) : super([]) {
    load();
  }

  Future<void> load() async {
    state = await repo.getAllProducts();
  }

  Future<void> add(Product p) async {
    await repo.addProduct(p);
    await load();
  }

  Future<void> delete(int id) async {
    await repo.deleteProduct(id);
    await load();
  }

  Future<void> updateStock(int id, int newStock) async {
    await repo.updateStock(id, newStock);
    await load();
  }

  Future<void> reloadStock(int id) async {
    final product = await repo.getById(id);
    if (product != null) {
      state = [
        for (final p in state)
          if (p.id == id) product else p,
      ];
    }
  }

  Future<Product?> getById(int id) async {
    return await repo.getById(id);
  }

  /// 🔹 Hàm giảm tồn kho theo số lượng
  Future<void> decreaseStock(int id, int amount) async {
    final product = await repo.getById(id);
    if (product != null) {
      final newStock = (product.stock - amount >= 0) ? product.stock - amount : 0;
      await repo.updateStock(id, newStock);
      await reloadStock(id);
    }
  }

  /// 🔹 Hàm tăng tồn kho theo số lượng
  Future<void> increaseStock(int id, int amount) async {
    final product = await repo.getById(id);
    if (product != null) {
      final newStock = product.stock + amount;
      await repo.updateStock(id, newStock);
      await reloadStock(id);
    }
  }
}
