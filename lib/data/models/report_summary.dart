class ReportSummary {
  final double profit;       // Lợi nhuận
  final double revenue;      // Doanh thu
  final int invoiceCount;    // Số lượng hóa đơn
  final double invoiceValue; // Giá trị hóa đơn
  final double tax;          // Thuế
  final double discount;     // Chiết khấu
  final double fee;          // Phụ phí (mới thêm)
  final double cost;         // Vốn
  final double cash;         // Tiền mặt
  final double bank;         // Ngân hàng
  final double debt;         // Công nợ

  ReportSummary({
    required this.profit,
    required this.revenue,
    required this.invoiceCount,
    required this.invoiceValue,
    required this.tax,
    required this.discount,
    required this.fee,
    required this.cost,
    required this.cash,
    required this.bank,
    required this.debt,
  });
}
