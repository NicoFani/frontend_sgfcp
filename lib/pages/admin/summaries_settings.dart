import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/models/summary_data.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

class SummariesSettingsPageAdmin extends StatefulWidget {
  const SummariesSettingsPageAdmin({super.key});

  static const String routeName = '/admin/summaries-settings';

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const SummariesSettingsPageAdmin(),
    );
  }
  
  @override
  State<StatefulWidget> createState() => _SummariesSettingsPageAdminState();
}

class _SummariesSettingsPageAdminState extends State<SummariesSettingsPageAdmin> {
  bool _useLastDay = true;
  int _specificDay = 1;
  String _email = 'estudiocontable@gmail.com';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    final dateSubtitle = _useLastDay
        ? 'Último día de cada mes'
        : 'Día $_specificDay de cada mes';

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de resúmenes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Fecha de generación del resumen
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Fecha de generación del resumen', style: textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: Text(dateSubtitle),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _openDaySelectorDialog,
          ),
          const Divider(height: 1),

          // Email de envío de resúmenes
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Email de envío de resúmenes', style: textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(_email),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _openEmailDialog,
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Listado de estados de resumen', style: textTheme.titleMedium),
          ),

          // Estado explicativos
          ...SummaryStatus.values.map((s) {
            final iconColor = s.color(colors);
            return ListTile(
              leading: Icon(s.icon, color: iconColor),
              title: Text(s.label),
              visualDensity: const VisualDensity(vertical: -4),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _openDaySelectorDialog() async {
    bool localUseLastDay = _useLastDay;
    int localSpecificDay = _specificDay;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setLocalState) {
          return AlertDialog(
            title: const Text('Fecha de generación'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<bool>(
                  value: true,
                  groupValue: localUseLastDay,
                  onChanged: (v) => setLocalState(() => localUseLastDay = true),
                  title: const Text('Último día de cada mes'),
                ),
                RadioListTile<bool>(
                  value: false,
                  groupValue: localUseLastDay,
                  onChanged: (v) => setLocalState(() => localUseLastDay = false),
                  title: Row(
                    children: [
                      const Text('Día específico'),
                      const SizedBox(width: 12),
                      if (!localUseLastDay)
                        DropdownButton<int>(
                          value: localSpecificDay,
                          items: List.generate(31, (i) => i + 1)
                              .map((d) => DropdownMenuItem<int>(
                                    value: d,
                                    child: Text('$d'),
                                  ))
                              .toList(),
                          onChanged: (v) => setLocalState(() {
                            if (v != null) localSpecificDay = v;
                          }),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _useLastDay = localUseLastDay;
                    _specificDay = localSpecificDay;
                  });
                  Navigator.of(ctx).pop();
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _openEmailDialog() async {
    final controller = TextEditingController(text: _email);
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setLocalState) {
          return AlertDialog(
            title: const Text('Email de envío de resúmenes'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'nombre@dominio.com',
                errorText: errorText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  final value = controller.text.trim();
                  final isValid = isValidEmail(value);
                  setLocalState(() => errorText = isValid ? null : 'Email inválido');
                  if (isValid) {
                    setState(() => _email = value);
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        });
      },
    );
  }
}
