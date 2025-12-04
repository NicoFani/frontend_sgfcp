import 'package:flutter/material.dart';

import 'package:frontend_sgfcp/pages/driver/personal_data.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class EditPersonalDataPage extends StatelessWidget {
  const EditPersonalDataPage({super.key});

  static const String routeName = '/edit_personal_data';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const EditPersonalDataPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar datos personales'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [          
              // Nombre(s)
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nombre(s)',
                  border: OutlineInputBorder(),
                ),
              ),

              gap12,

              // Apellido(s)
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Apellido(s)',
                  border: OutlineInputBorder(),
                ),
              ),

              gap12,

              // CUIL
              TextField(
                decoration: const InputDecoration(
                  labelText: 'CUIL',
                  border: OutlineInputBorder(),
                ),
              ),

              gap12,

              // CVU
              TextField(
                decoration: const InputDecoration(
                  labelText: 'CVU',
                  border: OutlineInputBorder(),
                ),
              ),

              gap12,

              // Número de teléfono
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Número de teléfono',
                  border: OutlineInputBorder(),
                ),
              ),

              gap16,

              // Botón principal
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  Navigator.of(context).push(PersonalDataPage.route());
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