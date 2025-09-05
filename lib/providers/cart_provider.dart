import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_product.dart';
import '../data/models/customer.dart';
import '../data/repositories/cart_repository.dart';
import 'cart_state.dart';
import '../data/models/amount_value.dart';

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

// Quản lý giỏ hàng
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// Chiết khấu
final discountProvider =
StateProvider<AmountValue>((ref) => AmountValue(0, "Tiền mặt"));

// Phụ phí
final surchargeProvider =
StateProvider<AmountValue>((ref) => AmountValue(0, "Tiền mặt"));

// Thuế
final taxProvider =
StateProvider<AmountValue>((ref) => AmountValue(0, "Tiền mặt"));

// Ghi chú
final noteProvider = StateProvider<String>((ref) => "");


//hàm tính tổng
double calculateFinalTotal({
  required double baseTotal,
  required AmountValue discount,
  required AmountValue surcharge,
  required AmountValue tax,
}) {
  double finalTotal = baseTotal;

  // Trừ chiết khấu
  if (discount.type == "%") {
    finalTotal -= baseTotal * (discount.value / 100);
  } else {
    finalTotal -= discount.value;
  }

  // Cộng phụ phí
  if (surcharge.type == "%") {
    finalTotal += baseTotal * (surcharge.value / 100);
  } else {
    finalTotal += surcharge.value;
  }

  // Cộng thuế
  if (tax.type == "%") {
    finalTotal += baseTotal * (tax.value / 100);
  } else {
    finalTotal += tax.value;
  }

  // Không cho tổng < 0
  if (finalTotal < 0) finalTotal = 0;

  return finalTotal;
}
