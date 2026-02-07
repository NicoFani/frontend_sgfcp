import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:frontend_sgfcp/theme/spacing.dart';

class CheckboxTextField extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final TextEditingController controller;
  final bool enabled;
  final String checkboxLabel;
  final String textFieldLabel;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;

  const CheckboxTextField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.controller,
    required this.enabled,
    required this.checkboxLabel,
    required this.textFieldLabel,
    this.keyboardType,
    this.inputFormatters,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
            ),
            Expanded(
              child: Text(checkboxLabel),
            ),
          ],
        ),
        if (value) ...[
          gap8,
          TextField(
            enabled: enabled,
            controller: controller,
            decoration: InputDecoration(
              labelText: textFieldLabel,
              border: const OutlineInputBorder(),
              prefixText: prefixText,
            ),
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
          ),
          gap12,
        ],
      ],
    );
  }
}
