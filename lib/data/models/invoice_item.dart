class InvoiceItem {
  final int? id;
  final int invoiceId;
  final int? productId;
  final String name;
  final double price;
  final int quantity;
  final double tax;      // ✅ Thuế
  final double fee;      // ✅ Phụ phí
  final double discount; // ✅ Chiết khấu

  InvoiceItem({
    this.id,
    required this.invoiceId,
    this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.tax = 0,        // mặc định 0
    this.fee = 0,        // mặc định 0
    this.discount = 0,   // mặc định 0
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'tax': tax,
      'fee': fee,
      'discount': discount,
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
      tax: (map['tax'] as num?)?.toDouble() ?? 0,
      fee: (map['fee'] as num?)?.toDouble() ?? 0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
    );
  }
}
