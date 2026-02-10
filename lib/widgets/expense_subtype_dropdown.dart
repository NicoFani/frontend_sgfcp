import 'package:flutter/material.dart';

class ExpenseSubtypeDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? value;
  final String? errorText;
  final ValueChanged<String?> onChanged;

  const ExpenseSubtypeDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<String>(
          width: constraints.maxWidth,
          label: Text(label),
          errorText: errorText,
          initialSelection: value,
          dropdownMenuEntries: [
            for (final opt in options)
              DropdownMenuEntry(value: opt, label: opt),
          ],
          onSelected: onChanged,
        );
      },
    );
  }
}
