import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

bool isValidEmail(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;
  final atCount = '@'.allMatches(trimmed).length;
  return atCount == 1 && trimmed.contains('.');
}

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

String formatPlate(String value) {
  // Extract alphanumeric characters only
  final alphanumeric = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
  final clipped = alphanumeric.length > 7 ? alphanumeric.substring(0, 7) : alphanumeric;
  
  if (clipped.isEmpty) return '';
  
  // If 6 chars: XXX 000 (old format)
  if (clipped.length <= 3) return clipped;
  if (clipped.length <= 6) {
    return '${clipped.substring(0, 3)} ${clipped.substring(3)}';
  }
  
  // If 7 chars: XX 000 XX (new format)
  if (clipped.length <= 2) return clipped;
  if (clipped.length <= 5) {
    return '${clipped.substring(0, 2)} ${clipped.substring(2)}';
  }
  return '${clipped.substring(0, 2)} ${clipped.substring(2, 5)} ${clipped.substring(5)}';
}

bool isValidPlate(String value) {
  // Remove spaces and convert to uppercase
  final plate = value.replaceAll(' ', '').toUpperCase();
  
  // Must be 6 or 7 characters
  if (plate.length != 6 && plate.length != 7) return false;
  
  if (plate.length == 6) {
    // Old format: 3 letters + 3 numbers (e.g., ABC 123)
    final letters = plate.substring(0, 3);
    final numbers = plate.substring(3, 6);
    return RegExp(r'^[A-Z]{3}$').hasMatch(letters) && RegExp(r'^[0-9]{3}$').hasMatch(numbers);
  } else {
    // New format: 2 letters + 3 numbers + 2 letters (e.g., AB 123 CD)
    final firstLetters = plate.substring(0, 2);
    final numbers = plate.substring(2, 5);
    final lastLetters = plate.substring(5, 7);
    return RegExp(r'^[A-Z]{2}$').hasMatch(firstLetters) &&
        RegExp(r'^[0-9]{3}$').hasMatch(numbers) &&
        RegExp(r'^[A-Z]{2}$').hasMatch(lastLetters);
  }
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

class PlateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final alphanumeric = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    final clipped = alphanumeric.length > 7 ? alphanumeric.substring(0, 7) : alphanumeric;

    String formatted;
    if (clipped.length <= 3) {
      formatted = clipped;
    } else if (clipped.length <= 6) {
      // Format as XXX 000
      formatted = '${clipped.substring(0, 3)} ${clipped.substring(3)}';
    } else {
      // Format as XX 000 XX
      formatted = '${clipped.substring(0, 2)} ${clipped.substring(2, 5)} ${clipped.substring(5)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}