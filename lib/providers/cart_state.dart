import '../data/models/cart_product.dart';
import '../data/models/customer.dart';
import '../data/models/amount_value.dart';

class CartState {
  final List<CartProduct> items;
  final Customer? customer;

  // ✅ Cho nullable để tránh crash
  final AmountValue? discount;
  final AmountValue? surcharge;
  final AmountValue? tax;

  CartState({
    required this.items,
    this.customer,
    this.discount,
    this.surcharge,
    this.tax,
  });

  CartState copyWith({
    List<CartProduct>? items,
    Customer? customer,
    AmountValue? discount,
    AmountValue? surcharge,
    AmountValue? tax,
  }) {
    return CartState(
      items: items ?? this.items,
      customer: customer ?? this.customer,
      discount: discount ?? this.discount,
      surcharge: surcharge ?? this.surcharge,
      tax: tax ?? this.tax,
    );
  }

  // ✅ Getter an toàn, luôn trả về mặc định nếu null
  AmountValue get safeDiscount => discount ?? AmountValue(0, "fixed");
  AmountValue get safeSurcharge => surcharge ?? AmountValue(0, "fixed");
  AmountValue get safeTax => tax ?? AmountValue(0, "fixed");

  double get total => items.fold(0, (sum, item) => sum + item.total);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
