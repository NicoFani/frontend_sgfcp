import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/pages/admin/create_client_provider.dart';

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
    final textTheme = Theme.of(context).textTheme;

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
                builder: (context) => const CreateClientProviderPageAdmin(),
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
                  Expanded(
                    child: _TabButton(
                      label: 'Clientes',
                      isSelected: _showingClients,
                      backgroundColor: colors.primary,
                      onTap: () {
                        setState(() {
                          _showingClients = true;
                        });
                      },
                    ),
                  ),
                  gapW8,
                  Expanded(
                    child: _TabButton(
                      label: 'Dadores',
                      isSelected: !_showingClients,
                      backgroundColor: colors.secondaryContainer,
                      onTap: () {
                        setState(() {
                          _showingClients = false;
                        });
                      },
                    ),
                  ),
                ],
              ),

              gap16,

              // Lista con líneas divisoras
              Expanded(
                child: ListView.separated(
                  itemCount: currentList.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: colors.outlineVariant,
                  ),
                  itemBuilder: (context, index) {
                    return _ListItem(
                      name: currentList[index],
                      onTap: () {
                        // TODO: Navegar a detalle
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Detalle de ${currentList[index]} - En desarrollo'),
                          ),
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
    final textTheme = Theme.of(context).textTheme;

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: isSelected ? backgroundColor : colors.surfaceContainerHighest,
        foregroundColor: isSelected 
          ? (backgroundColor == colors.primary ? colors.onPrimary : colors.onSecondaryContainer)
          : colors.onSurface,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _ListItem({
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: textTheme.bodyLarge,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
