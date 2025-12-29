import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/pages/admin/home.dart';
import 'package:frontend_sgfcp/pages/admin/notifications.dart';
import 'package:frontend_sgfcp/pages/admin/trips.dart';
import 'package:frontend_sgfcp/pages/admin/drivers.dart';
import 'package:frontend_sgfcp/pages/admin/create_driver.dart';
import 'package:frontend_sgfcp/pages/admin/administration.dart';

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

  final List<Widget> _pages = const [
    HomePageAdmin(),
    TripsPageAdmin(),
    DriversPageAdmin(),
    AdministrationPageAdmin(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // APPBAR según la pestaña seleccionada
  PreferredSizeWidget? _buildAppBar() {   
    switch (_selectedIndex) {
      case 0:
        return AppBar(
          title: Text(
            'Hola, Omar!',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsPageAdmin(),
                  ),
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
              onPressed: () {
                Navigator.of(context).push(CreateDriverPageAdmin.route());
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
    return Scaffold(
      appBar: _buildAppBar(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
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
  }
}
