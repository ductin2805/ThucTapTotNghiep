import 'package:intl/intl.dart';
import '../data/models/amount_value.dart';
/// Dùng chung cho tất cả format tiền VNĐ
final _vndFormatter = NumberFormat.decimalPattern('vi_VN');

/// Format tiền VNĐ (không có dấu thập phân, KHÔNG có chữ "đ")
String formatCurrency(num value) {
  return _vndFormatter.format(value);
}

/// Format ngày giờ: dd/MM/yyyy HH:mm
String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
}

/// Format ngày: dd/MM/yyyy
String formatDate(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy').format(dateTime);
}
/// Hiển thị AmountValue dưới dạng chuỗi
/// - Nếu là "Tiền mặt": 12,000
/// - Nếu là "%": 10 %
String displayAmount(AmountValue value) {
  if (value.type == "Tiền mặt") {
    return formatCurrency(value.value);
  } else if (value.type == "%") {
    return "${value.value.toStringAsFixed(0)} %";
  }
  return value.value.toString();
}
