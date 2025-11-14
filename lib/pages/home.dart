import 'package:flutter/material.dart';

/// A starter Home page for the app.
///
/// Replace the placeholder widgets and TODOs with your actual UI.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// Route name you can use with Navigator.pushNamed
  static const String routeName = '/home';

  /// Helper to create a route to this page
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.home_filled,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to the Home page',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Replace this with your page content.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Hook up action for FAB
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('FAB pressed — add action')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
