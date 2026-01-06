import 'package:flutter/material.dart';

class SimpleTableRowData {
  final String col1;
  final String col2;
  final DateTime? dateToValidate;
  final VoidCallback onEdit;

  const SimpleTableRowData({
    required this.col1,
    required this.col2,
    this.dateToValidate,      // null si no aplica
    required this.onEdit,
  });
}
