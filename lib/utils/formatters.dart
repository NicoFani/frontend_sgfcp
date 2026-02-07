import 'dart:math' as math;

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