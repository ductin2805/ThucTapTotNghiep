class ReportSummary {
  final double profit;       // lợi nhuận
  final double revenue;      // doanh thu
  final int invoiceCount;    // số hóa đơn
  final double invoiceValue; // tổng giá trị hóa đơn
  final double tax;          // tiền thuế
  final double discount;     // giảm giá (nếu có)
  final double cost;         // tiền vốn
  final double cash;         // tiền mặt
  final double bank;         // ngân hàng
  final double debt;         // khách nợ

  ReportSummary({
    required this.profit,
    required this.revenue,
    required this.invoiceCount,
    required this.invoiceValue,
    required this.tax,
    required this.discount,
    required this.cost,
    required this.cash,
    required this.bank,
    required this.debt,
  });
}
