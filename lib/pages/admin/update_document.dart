import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class UpdateDocumentPageAdmin extends StatefulWidget {
  final String documentName;
  final DateTime currentDate;

  const UpdateDocumentPageAdmin({
    super.key,
    required this.documentName,
    required this.currentDate,
  });

  static const String routeName = '/admin/update-document';

  static Route route({
    required String documentName,
    required DateTime currentDate,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => UpdateDocumentPageAdmin(
        documentName: documentName,
        currentDate: currentDate,
      ),
    );
  }

  @override
  State<UpdateDocumentPageAdmin> createState() => _UpdateDocumentPageAdminState();
}

class _UpdateDocumentPageAdminState extends State<UpdateDocumentPageAdmin> {
  DateTime? _newExpirationDate;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializar con la fecha actual del documento
    _newExpirationDate = widget.currentDate;
    _dateController.text = DateFormat('dd/MM/yyyy').format(widget.currentDate);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _newExpirationDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() {
        _newExpirationDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _saveChanges() {
    // TODO: Guardar cambios en el backend
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vencimiento actualizado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentación'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del documento
              Text(
                'Actualizar vencimiento',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              gap8,

              Text(
                widget.documentName,
                style: textTheme.titleMedium,
              ),

              gap24,

              // Campo de fecha
              TextField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha de vencimiento',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onTap: _pickDate,
              ),

              const Spacer(),

              // Botón Guardar cambios
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _saveChanges,
                icon: const Icon(Symbols.check),
                label: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
