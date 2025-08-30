class Invoice {
  final int? id;
  final String code;
  final String createdAt;
  final String customer;
  final double total;
  final double paid;
  final double debt;
  final String method;

  Invoice({
    this.id,
    required this.code,
    required this.createdAt,
    required this.customer,
    required this.total,
    required this.paid,
    required this.debt,
    required this.method,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'createdAt': createdAt,
      'customer': customer,
      'total': total,
      'paid': paid,
      'debt': debt,
      'method': method,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      code: map['code'],
      createdAt: map['createdAt'],
      customer: map['customer'],
      total: map['total'],
      paid: map['paid'],
      debt: map['debt'],
      method: map['method'],
    );
  }
}
