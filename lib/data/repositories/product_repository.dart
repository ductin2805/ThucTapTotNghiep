import '../dao/product_dao.dart';
import '../models/product.dart';

class ProductRepository {
  final _dao = ProductDao();

  Future<int> addProduct(Product product) => _dao.insert(product);
  Future<List<Product>> fetchProducts() => _dao.getAll();
  Future<int> updateProduct(Product product) => _dao.update(product);
  Future<int> deleteProduct(int id) => _dao.delete(id);
  Future<List<Product>> getAllProducts() => _dao.getAll();
  Future<Product?> getById(int id) async => _dao.getById(id);
  Future<void> updateStock(int id, int newStock) async {
    await _dao.updateStock(id, newStock);
  }
}
