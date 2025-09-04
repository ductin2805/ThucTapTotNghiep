import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_product.dart';
import '../data/models/customer.dart';
import '../data/repositories/cart_repository.dart';
import 'cart_state.dart';

class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _repo = CartRepository();

  CartNotifier() : super(CartState(items: [])) {
    loadCart();
  }

  /// Load giỏ hàng từ repository
  Future<void> loadCart() async {
    final items = await _repo.getCartProducts();
    state = state.copyWith(items: items);
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
    state = CartState(items: []); // reset cả giỏ lẫn khách hàng
  }

  /// Gắn khách hàng vào giỏ
  void setCustomer(Customer? customer) {
    state = state.copyWith(customer: customer);
  }
}

final cartProvider =
StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
})

;
