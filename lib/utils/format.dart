import 'package:intl/intl.dart';

/// Format tiền VNĐ (không có dấu thập phân, thêm chữ "đ")
String formatCurrency(num value) {
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);
  return "${formatter.format(value)} đ";
}

/// Format ngày giờ: dd/MM/yyyy HH:mm
String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
}

/// Format ngày: dd/MM/yyyy
String formatDate(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy').format(dateTime);
}
