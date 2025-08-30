class InvoiceItem {
  final int? id;
  final int invoiceId;
  final int? productId;
  final String name;
  final double price;
  final int quantity;

  InvoiceItem({
    this.id,
    required this.invoiceId,
    this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'],
      invoiceId: map['invoice_id'],
      productId: map['product_id'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }
}
