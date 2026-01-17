import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/widgets/create_client_provider.dart';
import 'package:frontend_sgfcp/services/client_service.dart';
import 'package:frontend_sgfcp/services/load_owner_service.dart';
import 'package:frontend_sgfcp/models/client_data.dart';
import 'package:frontend_sgfcp/models/load_owner_data.dart';

class ClientsProvidersPageAdmin extends StatefulWidget {
  const ClientsProvidersPageAdmin({super.key});

  static const String routeName = '/admin/clients-providers';

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ClientsProvidersPageAdmin(),
    );
  }

  @override
  State<ClientsProvidersPageAdmin> createState() =>
      _ClientsProvidersPageAdminState();
}

class _ClientsProvidersPageAdminState extends State<ClientsProvidersPageAdmin> {
  bool _showingClients = true;
  late Future<List<ClientData>> _clientsFuture;
  late Future<List<LoadOwnerData>> _loadOwnersFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _clientsFuture = ClientService.getClients();
      _loadOwnersFuture = LoadOwnerService.getLoadOwners();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes y dadores'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add),
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (context) => const ClientProviderDialog(),
              );
              if (result == true) {
                _loadData();
              }
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

              // Lista con datos dinámicos
              Expanded(
                child: _showingClients
                    ? _buildClientsList()
                    : _buildLoadOwnersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClientsList() {
    return FutureBuilder<List<ClientData>>(
      future: _clientsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(
            'Error al cargar clientes',
            snapshot.error.toString(),
          );
        }

        final clients = snapshot.data ?? [];

        if (clients.isEmpty) {
          return _buildEmptyWidget(
            'No hay clientes registrados',
            'Presiona el botón + para agregar uno',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _loadData();
            await _clientsFuture;
          },
          child: ListView.separated(
            itemCount: clients.length,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(height: 1),
            ),
            itemBuilder: (context, index) {
              final client = clients[index];
              return ListTile(
                title: Text(client.name),
                trailing: const Icon(Icons.arrow_right),
                onTap: () async {
                  final result = await showDialog(
                    context: context,
                    builder: (context) => ClientProviderDialog.edit(
                      entityId: client.id,
                      initialName: client.name,
                      initialType: 'Cliente',
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadOwnersList() {
    return FutureBuilder<List<LoadOwnerData>>(
      future: _loadOwnersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(
            'Error al cargar dadores',
            snapshot.error.toString(),
          );
        }

        final loadOwners = snapshot.data ?? [];

        if (loadOwners.isEmpty) {
          return _buildEmptyWidget(
            'No hay dadores de carga registrados',
            'Presiona el botón + para agregar uno',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _loadData();
            await _loadOwnersFuture;
          },
          child: ListView.separated(
            itemCount: loadOwners.length,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(height: 1),
            ),
            itemBuilder: (context, index) {
              final loadOwner = loadOwners[index];
              return ListTile(
                title: Text(loadOwner.name),
                trailing: const Icon(Icons.arrow_right),
                onTap: () async {
                  final result = await showDialog(
                    context: context,
                    builder: (context) => ClientProviderDialog.edit(
                      entityId: loadOwner.id,
                      initialName: loadOwner.name,
                      initialType: 'Dador',
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Symbols.person_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
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
          backgroundColor: isSelected
              ? colors.secondaryContainer
              : colors.surfaceContainerHighest,
          foregroundColor: isSelected
              ? colors.onSecondaryContainer
              : colors.onSurfaceVariant,
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
