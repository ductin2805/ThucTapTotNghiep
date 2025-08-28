import '../dao/cart_dao.dart';
import '../dao/product_dao.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/cart_product.dart';

class CartRepository {
  final CartDao _cartDao = CartDao();
  final ProductDao _productDao = ProductDao();

  /// Thêm sản phẩm vào giỏ
  Future<void> addToCart(int productId, {int quantity = 1}) async {
    final items = await _cartDao.getAll();

    // kiểm tra nếu sản phẩm đã có trong giỏ thì tăng số lượng
    final existing = items.where((e) => e.productId == productId).toList();
    if (existing.isNotEmpty) {
      final item = existing.first;
      await _cartDao.updateQuantity(item.id!, item.quantity + quantity);
    } else {
      await _cartDao.insert(CartItem(productId: productId, quantity: quantity));
    }
  }

  /// Lấy toàn bộ giỏ hàng (CartProduct = CartItem + Product)
  Future<List<CartProduct>> getCartProducts() async {
    final items = await _cartDao.getAll();
    final products = await _productDao.getAll();

    return items.map((item) {
      final product = products.firstWhere((p) => p.id == item.productId);
      return CartProduct(item: item, product: product);
    }).toList();
  }

  /// Cập nhật số lượng trong giỏ
  Future<void> updateQuantity(int cartItemId, int quantity) async {
    await _cartDao.updateQuantity(cartItemId, quantity);
  }

  /// Xóa một sản phẩm khỏi giỏ
  Future<void> removeFromCart(int cartItemId) async {
    await _cartDao.delete(cartItemId);
  }

  /// Xóa toàn bộ giỏ hàng
  Future<void> clearCart() async {
    await _cartDao.clear();
  }
}
