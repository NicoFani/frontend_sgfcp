import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/pages/admin/home.dart';
import 'package:frontend_sgfcp/pages/shared/notifications.dart';
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
  final ValueNotifier<int> _driversRefreshNotifier = ValueNotifier(0);

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePageAdmin(),
      const TripsPageAdmin(),
      ValueListenableBuilder<int>(
        valueListenable: _driversRefreshNotifier,
        builder: (context, value, child) =>
            DriversPageAdmin(key: ValueKey(value)),
      ),
      const AdministrationPageAdmin(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _driversRefreshNotifier.dispose();
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
