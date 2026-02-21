import 'package:flutter/material.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/main.dart';
import 'package:frontend_sgfcp/pages/admin/admin_root_navigation.dart';
import 'package:frontend_sgfcp/services/auth_service.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/utils/formatters.dart';

/// Pantalla de inicio de sesión
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginPage());
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final String logoLocation = 'assets/images/logo_mockup_gemini_no_background.png';

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Llamar a la autenticación real del backend
    final result = await AuthService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Guardar tokens y usuario
        TokenStorage.saveTokens(
          accessToken: result['access_token'],
          refreshToken: result['refresh_token'],
          user: result['user'],
        );

        // Determinar el rol desde la respuesta del backend
        final user = result['user'] as Map<String, dynamic>;
        final isAdmin = user['is_admin'] as bool? ?? false;

        if (isAdmin) {
          // Navegar a pantallas de administrador
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminRootNavigation()),
          );
        } else {
          // Navegar a pantallas del chofer
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const RootNavigation()),
          );
        }
      } else {
        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al iniciar sesión'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // void _handleForgotPassword() {
  //   // TODO: Implementar recuperación de contraseña
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Funcionalidad de recuperación en desarrollo'),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 12),
                    child: Image.asset(
                      logoLocation,
                      fit: BoxFit.contain,
                      height: 140,
                    ),
                  ),

                  gap32,

                  // Campo de Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa tu email';
                      if (!isValidEmail(value)) return 'Por favor ingresa un email válido';
                      return null;
                    },
                  ),

                  gap12,

                  // Campo de Contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: '••••••••••',
                      border: OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),

                  gap24,

                  // Botón de Iniciar Sesión
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colors.onPrimary,
                                ),
                              ),
                            )
                          : Text(
                              'Iniciar sesión',
                              style: textTheme.titleMedium?.copyWith(
                                color: colors.onPrimary,
                              ),
                            ),
                    ),
                  ),

                  gap12,

                    // Forgot password
                    // SizedBox(
                    //   height: 36,
                    //   child: FilledButton.tonal(
                    //     onPressed: _handleForgotPassword,
                    //     child: Text(
                    //       'Olvidé mi contraseña',
                    //       style: textTheme.labelLarge?.copyWith(
                    //         color: colors.onSecondaryContainer,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //   ),
                    // ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
