import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend_sgfcp/pages/shared/login_page.dart';
import 'package:frontend_sgfcp/services/auth_service.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/pages/admin/admin_root_navigation.dart';
import 'package:frontend_sgfcp/main.dart';

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

    // ----------------- AUTOLOGIN FOR DEVELOPMENT PURPOSES -----------------
    // Si ya hay sesión en memoria, navegamos según rol
    if (TokenStorage.isAuthenticated && mounted) {
      final user = TokenStorage.user ?? {};
      final isAdmin = user['is_admin'] as bool? ?? false;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              isAdmin ? const AdminRootNavigation() : const RootNavigation(),
        ),
      );
      return;
    }

    // Auto-login solo en modo debug para desarrollo
    if (kDebugMode) {
      final result = await AuthService.login(
        // email: 'admin@sgfcp.com',
        email: 'maria.gonzalez@sgfcp.com',
        password: '123456',
      );

      if (result['success'] == true) {
        TokenStorage.saveTokens(
          accessToken: result['access_token'],
          refreshToken: result['refresh_token'],
          user: result['user'],
        );

        if (mounted) {
          final user = result['user'] as Map<String, dynamic>;
          final isAdmin = user['is_admin'] as bool? ?? false;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => isAdmin
                  ? const AdminRootNavigation()
                  : const RootNavigation(),
            ),
          );
        }
        return;
      }
      // Si falla el auto-login (backend no disponible, etc.), seguimos al LoginPage
    }

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
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
              'assets/images/logo_mockup_gemini_no_background.png',
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
          ],
        ),
      ),
    );
  }
}
