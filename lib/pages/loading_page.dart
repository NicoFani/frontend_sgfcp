import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/pages/login_page.dart';

/// Pantalla de carga inicial (Splash Screen)
class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  static const String routeName = '/loading';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const LoadingPage());
  }

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    // Simular carga inicial (2 segundos)
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                // Fallback: mostrar icono si no existe la imagen
                return Icon(
                  Icons.local_shipping_rounded,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary,
                );
              },
            ),
            const SizedBox(height: 16),
            // Nombre de la app
            Text(
              'mi Truck',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fleet Management System',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
