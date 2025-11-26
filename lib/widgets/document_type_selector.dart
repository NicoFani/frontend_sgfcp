import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

enum DocumentType { ctg, remito }

class DocumentTypeSelector extends StatelessWidget {
  final DocumentType selected;
  final ValueChanged<DocumentType> onChanged;

  const DocumentTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    Widget buildChip(DocumentType type, String label) {
      final bool isSelected = selected == type;

      return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onChanged(type),
      );
    }

    return Row(
      children: [
        buildChip(DocumentType.ctg, "CTG"),
        gapW8,
        buildChip(DocumentType.remito, "Remito"),
      ],
    );
  }
}
