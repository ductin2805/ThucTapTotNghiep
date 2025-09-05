import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../data/models/amount_value.dart';

/// Dùng chung cho tất cả format tiền VNĐ
final _vndFormatter = NumberFormat.decimalPattern('vi_VN');

/// Format tiền VNĐ (không có dấu thập phân, KHÔNG có chữ "đ")
String formatCurrency(num value) {
  return _vndFormatter.format(value);
}

/// Parse chuỗi tiền (ví dụ "1.234", "1.234,56", "1234") -> double
double parseCurrency(String input) {
  final s = input.trim();
  if (s.isEmpty) return 0.0;

  final cleaned = s.replaceAll(RegExp('[^0-9\\.,]'), '');

  try {
    if (cleaned.contains('.') && cleaned.contains(',')) {
      final normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(normalized) ?? 0.0;
    } else if (cleaned.contains(',')) {
      final normalized = cleaned.replaceAll(',', '.');
      return double.tryParse(normalized) ?? 0.0;
    } else {
      final normalized = cleaned.replaceAll('.', '');
      return double.tryParse(normalized) ?? 0.0;
    }
  } catch (e) {
    return 0.0;
  }
}

/// Parse và trả về int (làm tròn)
int parseCurrencyToInt(String input) => parseCurrency(input).round();

/// Format ngày giờ: dd/MM/yyyy HH:mm
String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
}

/// Format ngày: dd/MM/yyyy
String formatDate(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy').format(dateTime);
}

/// Hiển thị AmountValue dưới dạng chuỗi
String displayAmount(AmountValue value) {
  if (value.type == "Tiền mặt") {
    return formatCurrency(value.value);
  } else if (value.type == "%") {
    return "${value.value.toStringAsFixed(0)} %";
  }
  return value.value.toString();
}

/// ✅ Formatter để nhập số có phân cách ngàn
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat("#,##0", "vi_VN");

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');

    // bỏ dấu phân cách cũ
    String digits = newValue.text.replaceAll('.', '').replaceAll(',', '');
    final number = int.tryParse(digits);
    if (number == null) return oldValue;

    final newText = _formatter.format(number);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
