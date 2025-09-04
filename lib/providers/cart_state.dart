import '../data/models/cart_product.dart';
import '../data/models/customer.dart';

class CartState {
  final List<CartProduct> items;
  final Customer? customer;

  CartState({required this.items, this.customer});

  CartState copyWith({List<CartProduct>? items, Customer? customer}) {
    return CartState(
      items: items ?? this.items,
      customer: customer ?? this.customer,
    );
  }

  double get total => items.fold(0, (sum, item) => sum + item.total);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
