import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_product.dart';
import '../data/repositories/cart_repository.dart';

/// StateNotifier quản lý danh sách sản phẩm trong giỏ hàng
class CartNotifier extends StateNotifier<List<CartProduct>> {
  final CartRepository _repo = CartRepository();

  CartNotifier() : super([]) {
    loadCart();
  }

  /// Load giỏ hàng từ repository
  Future<void> loadCart() async {
    final items = await _repo.getCartProducts();
    state = items;
  }

  /// Thêm sản phẩm vào giỏ
  Future<void> addToCart(int productId, {int quantity = 1}) async {
    await _repo.addToCart(productId, quantity: quantity);
    await loadCart();
  }

  /// Cập nhật số lượng
  Future<void> updateQuantity(int cartItemId, int quantity) async {
    await _repo.updateQuantity(cartItemId, quantity);
    await loadCart();
  }

  /// Xóa một sản phẩm khỏi giỏ
  Future<void> removeFromCart(int cartItemId) async {
    await _repo.removeFromCart(cartItemId);
    await loadCart();
  }

  /// Xóa toàn bộ giỏ hàng (dùng sau thanh toán)
  Future<void> clearCart() async {
    await _repo.clearCart();
    await loadCart();
  }

  /// Tính tổng tiền
  double get total => state.fold(0, (sum, item) => sum + item.total);
}

/// Provider cho giỏ hàng
final cartProvider =
StateNotifierProvider<CartNotifier, List<CartProduct>>((ref) {
  return CartNotifier();
});
