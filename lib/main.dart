import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'theme/util.dart';
import 'theme/theme.dart';

import 'package:frontend_sgfcp/pages/driver/my_trips.dart';
import 'package:frontend_sgfcp/pages/driver/home.dart';
import 'package:frontend_sgfcp/pages/driver/profile.dart';
import 'package:frontend_sgfcp/pages/shared/loading_page.dart';
import 'package:frontend_sgfcp/pages/shared/notifications.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/notification_service.dart';

Future<void> main() async {
  // Inicializa datos de fechas para español
  await initializeDateFormatting('es_AR', null);
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme = createTextTheme(context, "Noto Sans", "Noto Sans");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'SGFCP',
      theme: theme
          .light(), // brightness == Brightness.light ? theme.light() : theme.dark(),
      locale: const Locale('es', 'AR'),
      supportedLocales: const [Locale('es', 'AR'), Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LoadingPage(),
    );
  }
}

/// Widget raíz con NavigationBar (Material 3) y las 3 pantallas principales.
class RootNavigation extends StatefulWidget {
  const RootNavigation({super.key});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  String _userName = 'Conductor';
  int _unreadCount = 0;

  final List<Widget> _pages = const [
    HomePageDriver(),
    MiTripsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      setState(() {
        _unreadCount = count;
      });
    } catch (_) {
      setState(() {
        _unreadCount = 0;
      });
    }
  }

  void _loadUserName() {
    final user = TokenStorage.user;
    setState(() {
      _userName = user?['name'] ?? 'Conductor';
    });
  }

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
            'Hola, $_userName!',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(NotificationsPage.route())
                    .then((_) => _loadUnreadCount());
              },
              icon: _unreadCount > 0
                  ? Badge.count(
                      count: _unreadCount,
                      child: const Icon(Icons.notifications_outlined),
                    )
                  : const Icon(Icons.notifications_outlined),
            ),
          ],
        );
      case 1:
        return AppBar(
          title: Text(
            'Mis viajes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        );
      case 2:
        return AppBar(
          title: Text(
            'Tu Perfil',
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
            label: 'Mis viajes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
