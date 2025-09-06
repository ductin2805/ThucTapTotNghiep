class Payment {
  final int? id;
  final double total;
  final double paid;
  final double change;
  final String method; // "cash" | "bank"
  final DateTime createdAt;

  Payment({
    this.id,
    required this.total,
    required this.paid,
    required this.change,
    required this.method,
    required this.createdAt,
  });

  /// chuyển object -> Map để insert vào DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'paid': paid,
      'change': change,
      'method': method,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// chuyển Map từ DB -> object Payment
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      total: map['total'] is int ? (map['total'] as int).toDouble() : map['total'],
      paid: map['paid'] is int ? (map['paid'] as int).toDouble() : map['paid'],
      change: map['change'] is int ? (map['change'] as int).toDouble() : map['change'],
      method: map['method'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
