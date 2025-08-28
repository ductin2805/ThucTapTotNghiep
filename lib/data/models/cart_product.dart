import 'cart_item.dart';
import 'product.dart';

class CartProduct {
  final CartItem item;
  final Product product;

  CartProduct({
    required this.item,
    required this.product,
  });

  // tiện ích: id của row trong bảng cart_items (có thể null nếu chưa insert)
  int? get id => item.id;

  // product_id liên kết tới product
  int get productId => item.productId;

  // số lượng trong cart
  int get quantity => item.quantity;

  // tổng tiền cho dòng này
  double get total => product.price * item.quantity;
}
