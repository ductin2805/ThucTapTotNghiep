class CartItem {
  final int? id;
  final int productId;
  final int quantity;

  CartItem({this.id, required this.productId, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      productId: map['product_id'],
      quantity: map['quantity'],
    );
  }
}
