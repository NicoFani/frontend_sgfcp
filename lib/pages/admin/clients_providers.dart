import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/widgets/create_client_provider.dart';

class ClientsProvidersPageAdmin extends StatefulWidget {
  const ClientsProvidersPageAdmin({super.key});

  static const String routeName = '/admin/clients-providers';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const ClientsProvidersPageAdmin());
  }

  @override
  State<ClientsProvidersPageAdmin> createState() => _ClientsProvidersPageAdminState();
}

class _ClientsProvidersPageAdminState extends State<ClientsProvidersPageAdmin> {
  bool _showingClients = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // TODO: Obtener datos reales del backend
    final clients = [
      'TBA',
      'Capeletti',
      'Miadini',
    ];

    final providers = [
      'Proveedor 1',
      'Proveedor 2',
      'Proveedor 3',
    ];

    final currentList = _showingClients ? clients : providers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes y dadores'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ClientProviderDialog(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Tabs Clientes / Dadores
              Row(
                children: [
                  _TabButton(
                    label: 'Clientes',
                    isSelected: _showingClients,
                    backgroundColor: colors.secondaryContainer,
                    onTap: () {
                      setState(() {
                        _showingClients = true;
                      });
                    },
                  ),
                  gapW8,
                  _TabButton(
                    label: 'Dadores',
                    isSelected: !_showingClients,
                    backgroundColor: colors.secondaryContainer,
                    onTap: () {
                      setState(() {
                        _showingClients = false;
                      });
                    },
                  ),
                ],
              ),

              gap16,
              
              // Lista con líneas divisoras
              Expanded(
                child: ListView.separated(
                  itemCount: currentList.length,
                  separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Divider(height: 1),
                  ),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(currentList[index]),
                      trailing: const Icon(Icons.arrow_right),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ClientProviderDialog.edit(),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      flex: isSelected ? 10 : 7,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: isSelected ? colors.secondaryContainer : colors.surfaceContainerHighest,
          foregroundColor: isSelected ? colors.onSecondaryContainer : colors.onSurfaceVariant,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}