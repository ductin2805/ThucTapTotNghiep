import '../dao/product_dao.dart';
import '../models/product.dart';

class ProductRepository {
  final ProductDao _dao = ProductDao();

  Future<List<Product>> getAllProducts() => _dao.getAll();
  Future<int> addProduct(Product p) => _dao.insert(p);
  Future<int> updateStock(int id, int stock) => _dao.updateStock(id, stock);
  Future<int> deleteProduct(int id) => _dao.delete(id);
}
