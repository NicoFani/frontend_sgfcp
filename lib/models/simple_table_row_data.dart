import 'package:flutter/material.dart';

class SimpleTableRowData {
  final String col1;
  final String col2;
  /// Nuevo: estado booleano
  final bool? isValid;
  final VoidCallback onEdit;

  const SimpleTableRowData({
    required this.col1,
    required this.col2,
    this.isValid,      // null si no aplica
    required this.onEdit,
  });
}
