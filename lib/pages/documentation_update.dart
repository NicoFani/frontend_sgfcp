import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend_sgfcp/pages/driver_documentation.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class DocumentationUpdatePage extends StatefulWidget {
  const DocumentationUpdatePage({super.key});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/documentation_update';

  /// Helper to create a route to this page
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const DocumentationUpdatePage());
  }
  @override
  State<DocumentationUpdatePage> createState() => _DocumentationUpdatePageState();
}

class _DocumentationUpdatePageState extends State<DocumentationUpdatePage> {

  DateTime? _expirationDate;
  final TextEditingController _expirationDateController = TextEditingController();
  
  get driver => null;
  
  @override
  void dispose() {
    _expirationDateController.dispose();
    super.dispose();
  }

  // Datepicker para seleccionar fecha de inicio
  Future<void> _pickexpirationDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _expirationDate = picked;

        final locale = Localizations.localeOf(context).toString();
        _expirationDateController.text =
            DateFormat('dd/MM/yyyy', locale).format(picked);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar vencimiento'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fecha de vencimiento
              TextField(
                controller: _expirationDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                onTap: _pickexpirationDate,
              ),
              
              gap16,

              // Botón principal
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  Navigator.of(context).push(DriverDocumentationPage.route(driver: driver));
                },
                icon: const Icon(Icons.check),
                label: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
