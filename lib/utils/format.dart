import 'package:intl/intl.dart';

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
