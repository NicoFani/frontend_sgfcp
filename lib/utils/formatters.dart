import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String formatCurrency(
  num value, {
  String locale = 'es_AR',
  String symbol = r'$',
  int decimalDigits = 2,
}) {
  final formatter = NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: decimalDigits,
  );

  return formatter.format(value);
}

double parseCurrency(String input, {String locale = 'es_AR'}) {
  // Remove currency symbols and clean the string
  final cleaned = input
      .replaceAll(RegExp(r'[^\d,.-]'), '') // Remove non-numeric except , . -
      .replaceAll('.', '') // Remove thousands separator
      .replaceAll(',', '.'); // Convert decimal separator to dot

  return double.parse(cleaned);
}

String formatDate(DateTime? date, {String format = 'dd/MM/yyyy', String? nullPlaceholder}) {
  if (date == null) return nullPlaceholder ?? '-';
  return DateFormat(format).format(date);
}

String formatCuil(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  final clipped = digits.length > 11 ? digits.substring(0, 11) : digits;
  if (clipped.isEmpty) return '';
  if (clipped.length <= 2) return clipped;
  if (clipped.length <= 10) {
    return '${clipped.substring(0, 2)}-${clipped.substring(2)}';
  }
  return '${clipped.substring(0, 2)}-${clipped.substring(2, 10)}-${clipped.substring(10)}';
}

String formatPhone(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  final clipped = digits.length > 10 ? digits.substring(0, 10) : digits;
  if (clipped.isEmpty) return '';
  if (clipped.length <= 4) return clipped;
  if (clipped.length <= 6) {
    return '${clipped.substring(0, 4)} ${clipped.substring(4)}';
  }
  return '${clipped.substring(0, 4)} ${clipped.substring(4, 6)}-${clipped.substring(6)}';
}

class CuilInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 11 ? digits.substring(0, 11) : digits;

    String formatted;
    if (clipped.length <= 2) {
      formatted = clipped;
    } else if (clipped.length <= 10) {
      formatted = '${clipped.substring(0, 2)}-${clipped.substring(2)}';
    } else {
      formatted =
          '${clipped.substring(0, 2)}-${clipped.substring(2, 10)}-${clipped.substring(10)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 10 ? digits.substring(0, 10) : digits;

    String formatted;
    if (clipped.length <= 4) {
      formatted = clipped;
    } else if (clipped.length <= 6) {
      formatted = '${clipped.substring(0, 4)} ${clipped.substring(4)}';
    } else {
      formatted =
          '${clipped.substring(0, 4)} ${clipped.substring(4, 6)}-${clipped.substring(6)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}