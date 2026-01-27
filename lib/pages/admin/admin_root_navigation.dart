import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/pages/admin/home.dart';
import 'package:frontend_sgfcp/pages/shared/notifications.dart';
import 'package:frontend_sgfcp/pages/admin/trips.dart';
import 'package:frontend_sgfcp/pages/admin/drivers.dart';
import 'package:frontend_sgfcp/pages/admin/create_driver.dart';
import 'package:frontend_sgfcp/pages/admin/administration.dart';
import 'package:frontend_sgfcp/services/auth_service.dart';
import 'package:frontend_sgfcp/models/user.dart';

/// Widget raíz de navegación para el administrador
class AdminRootNavigation extends StatefulWidget {
  const AdminRootNavigation({super.key});

  static const String routeName = '/admin';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const AdminRootNavigation());
  }

  @override
  State<AdminRootNavigation> createState() => _AdminRootNavigationState();
}

class _AdminRootNavigationState extends State<AdminRootNavigation> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final ValueNotifier<int> _driversRefreshNotifier = ValueNotifier(0);
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
  }

  Future<User> _fetchUser() async {
    final userData = await AuthService.getCurrentUser();
    if (userData['success'] != false && userData['user'] != null) {
      return User.fromJson(userData['user'] as Map<String, dynamic>);
    }
    throw Exception('No se pudo obtener los datos del usuario');
  }

  List<Widget> _buildPages(User user) {
    return [
      const HomePageAdmin(),
      const TripsPageAdmin(),
      ValueListenableBuilder<int>(
        valueListenable: _driversRefreshNotifier,
        builder: (context, value, child) =>
            DriversPageAdmin(key: ValueKey(value)),
      ),
      AdministrationPageAdmin(user: user),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _driversRefreshNotifier.dispose();
    super.dispose();
  }

  // APPBAR según la pestaña seleccionada
  PreferredSizeWidget? _buildAppBar(User? user) {
    switch (_selectedIndex) {
      case 0:
        final firstName = user?.firstName ?? 'Usuario';
        return AppBar(
          title: Text(
            'Hola, $firstName!',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
              icon: Badge.count(
                count: 3,
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
          ],
        );
      case 1:
        return AppBar(
          title: Text(
            'Viajes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        );
      case 2:
        return AppBar(
          title: Text(
            'Choferes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          actions: [
            IconButton(
              icon: const Icon(Symbols.person_add),
              onPressed: () async {
                final result = await Navigator.of(
                  context,
                ).push(CreateDriverPageAdmin.route());
                if (result == true) {
                  _driversRefreshNotifier.value++;
                }
              },
            ),
          ],
        );
      case 3:
        return AppBar(
          title: Text(
            'Administración',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        );
      default:
        return null;
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _userFuture = _fetchUser();
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('No se encontraron datos del usuario')),
          );
        }

        final user = snapshot.data!;
        final pages = _buildPages(user);

        return Scaffold(
          appBar: _buildAppBar(user),
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Symbols.delivery_truck_speed),
                selectedIcon: Icon(Symbols.delivery_truck_speed, fill: 1),
                label: 'Viajes',
              ),
              NavigationDestination(
                icon: Icon(Symbols.groups),
                selectedIcon: Icon(Symbols.groups, fill: 1),
                label: 'Choferes',
              ),
              NavigationDestination(
                icon: Icon(Symbols.supervisor_account),
                selectedIcon: Icon(Symbols.supervisor_account, fill: 1),
                label: 'Administración',
              ),
            ],
          ),
        );
      },
    );
  }
}
