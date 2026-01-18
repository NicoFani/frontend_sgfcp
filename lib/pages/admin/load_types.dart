import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/load_type_data.dart';
import 'package:frontend_sgfcp/services/load_type_service.dart';

class LoadTypesPageAdmin extends StatefulWidget {
  const LoadTypesPageAdmin({super.key});

  static const String routeName = '/admin/load-types';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const LoadTypesPageAdmin());
  }

  @override
  State<LoadTypesPageAdmin> createState() => _LoadTypesPageAdminState();
}

class _LoadTypesPageAdminState extends State<LoadTypesPageAdmin> {
  late Future<List<LoadTypeData>> _loadTypesFuture;

  @override
  void initState() {
    super.initState();
    _loadLoadTypes();
  }

  void _loadLoadTypes() {
    setState(() {
      _loadTypesFuture = LoadTypeService.getLoadTypes();
    });
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    bool defaultPerKm = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuevo Tipo de Carga'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              gap12,
              SwitchListTile(
                title: const Text('Cálculo por defecto'),
                subtitle: Text(defaultPerKm ? 'Por Kilómetro' : 'Por Tonelada'),
                value: defaultPerKm,
                onChanged: (value) {
                  setDialogState(() {
                    defaultPerKm = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingresa un nombre')),
                  );
                  return;
                }

                try {
                  await LoadTypeService.createLoadType(
                    name: nameController.text,
                    defaultCalculatedPerKm: defaultPerKm,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    _loadLoadTypes();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tipo de carga creado'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(LoadTypeData loadType) {
    final nameController = TextEditingController(text: loadType.name);
    bool defaultPerKm = loadType.defaultCalculatedPerKm;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Tipo de Carga'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              gap12,
              SwitchListTile(
                title: const Text('Cálculo por defecto'),
                subtitle: Text(defaultPerKm ? 'Por Kilómetro' : 'Por Tonelada'),
                value: defaultPerKm,
                onChanged: (value) {
                  setDialogState(() {
                    defaultPerKm = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await LoadTypeService.updateLoadType(
                    loadTypeId: loadType.id,
                    name: nameController.text,
                    defaultCalculatedPerKm: defaultPerKm,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    _loadLoadTypes();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tipo de carga actualizado'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteLoadType(LoadTypeData loadType) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tipo de Carga'),
        content: Text('¿Eliminar "${loadType.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await LoadTypeService.deleteLoadType(loadTypeId: loadType.id);
        if (mounted) {
          _loadLoadTypes();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tipo de carga eliminado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tipos de Carga')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Symbols.add),
        label: const Text('Nuevo Tipo'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<LoadTypeData>>(
          future: _loadTypesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Symbols.error, size: 48, color: colors.error),
                    gap12,
                    Text('Error: ${snapshot.error}'),
                  ],
                ),
              );
            }

            final loadTypes = snapshot.data ?? [];

            if (loadTypes.isEmpty) {
              return const Center(
                child: Text('No hay tipos de carga registrados'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: loadTypes.length,
              itemBuilder: (context, index) {
                final loadType = loadTypes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: loadType.defaultCalculatedPerKm
                          ? Colors.blue
                          : Colors.orange,
                      child: Icon(
                        loadType.defaultCalculatedPerKm
                            ? Symbols.route
                            : Symbols.scale,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(loadType.name),
                    subtitle: Text(
                      loadType.defaultCalculatedPerKm
                          ? 'Por Kilómetro'
                          : 'Por Tonelada',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Symbols.edit),
                          onPressed: () => _showEditDialog(loadType),
                        ),
                        IconButton(
                          icon: const Icon(Symbols.delete),
                          color: colors.error,
                          onPressed: () => _deleteLoadType(loadType),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
