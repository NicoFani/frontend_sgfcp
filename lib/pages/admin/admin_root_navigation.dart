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
    final colors = Theme.of(context).colorScheme;
    
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
                backgroundColor: colors.error,
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
    final colors = Theme.of(context).colorScheme;

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
        backgroundColor: colors.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Symbols.home),
            selectedIcon: Icon(Symbols.home, fill: 1),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Symbols.local_shipping),
            selectedIcon: Icon(Symbols.local_shipping, fill: 1),
            label: 'Viajes',
          ),
          NavigationDestination(
            icon: Icon(Symbols.group),
            selectedIcon: Icon(Symbols.group, fill: 1),
            label: 'Choferes',
          ),
          NavigationDestination(
            icon: Icon(Symbols.admin_panel_settings),
            selectedIcon: Icon(Symbols.admin_panel_settings, fill: 1),
            label: 'Administración',
          ),
        ],
      ),
    );
  }
}
